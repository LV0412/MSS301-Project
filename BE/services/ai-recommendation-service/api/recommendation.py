import logging
from typing import Any

from fastapi import APIRouter, Header

from clients.recipe_service_client import RecipeServiceClient, normalize_diet_type
from clients.user_service_client import UserServiceClient
from config import settings
from dto.request import RecommendationRequest
from dto.response import RecommendationResponse
from llm.foodyllm import FoodyLLM
from models.model_loader import ModelLoader
from optimizer.genetic import MealOptimizer
from prompt.prompt_builder import PromptBuilder
from rag.hybrid_search import HybridSearch
from rag.vector_store import RecipeDocument
from rules.rule_engine import RuleEngine


router = APIRouter()
logger = logging.getLogger(__name__)

model_loader = ModelLoader()
prompt_builder = PromptBuilder()
llm = FoodyLLM()
optimizer = MealOptimizer()
recipe_service_client = RecipeServiceClient()
user_service_client = UserServiceClient()
rule_engine = RuleEngine()


@router.post(
    "/recommendations",
    response_model=RecommendationResponse,
    summary="Generate food recommendations",
    description=(
        "Search Recipe Service internal recipes first, fall back to the local recipe corpus, "
        "apply rule filtering, build a RAG prompt, score recipes with FoodyLLM JSON, "
        "and optimize meal candidates."
    ),
    responses={
        200: {
            "description": "Recommendation response generated successfully.",
        },
        422: {
            "description": "Request validation failed.",
        },
    },
)
def recommend(
    request: RecommendationRequest,
    x_user_id: str | None = Header(default=None),
) -> RecommendationResponse:
    authenticated_request = request.model_copy(update={"user_id": x_user_id})
    user_profile = _load_user_profile(authenticated_request)
    enriched_request = _merge_profile(authenticated_request, user_profile)
    recipe_candidates = _load_recipe_candidates(enriched_request)
    rule_result = rule_engine.filter(recipe_candidates, enriched_request, user_profile)
    top_k_candidates = _run_hybrid_rag(enriched_request, rule_result.candidates)
    prompt = prompt_builder.build(enriched_request, top_k_candidates, user_profile, rule_result.warnings)
    llm_scores = llm.score_recipes(prompt, top_k_candidates, enriched_request, rule_result.warnings)
    optimized_items = optimizer.optimize(top_k_candidates, enriched_request, llm_scores)

    return RecommendationResponse(
        query=enriched_request.query,
        recommendations=optimized_items,
        explanation=_build_explanation(optimized_items, rule_result.warnings),
        stages=[
            "request_validation",
            "load_user_profile",
            "load_recipe_candidates",
            "rule_engine_filter",
            "hybrid_rag_top_k",
            "rag_prompt_builder",
            "foodyllm_json_scoring",
            "meal_optimization",
        ],
    )


def _load_user_profile(request: RecommendationRequest) -> dict[str, Any] | None:
    if not request.user_id:
        return None
    return user_service_client.get_ai_profile(request.user_id)


def _merge_profile(
    request: RecommendationRequest,
    user_profile: dict[str, Any] | None,
) -> RecommendationRequest:
    if not user_profile:
        return request

    nutrition_goal = _dict_value(user_profile, "nutritionGoal", "nutrition_goal")
    diet = _first_diet_preference(user_profile)
    allergen_tokens = _allergy_tokens(user_profile)

    updates = {
        "diet": request.diet or diet,
        "allergies": _unique([*request.allergies, *allergen_tokens]),
        "target_calories": request.target_calories or _per_meal_int(nutrition_goal, "calories"),
        "max_calories": request.max_calories or _per_meal_int(nutrition_goal, "calories", multiplier=1.25),
        "min_protein": request.min_protein or _per_meal_int(nutrition_goal, "protein", minimum=0),
        "max_carbs": request.max_carbs or _per_meal_int(nutrition_goal, "carbs", minimum=0),
        "max_fat": request.max_fat or _per_meal_int(nutrition_goal, "fat", minimum=0),
        "budget": request.budget or _int_value(user_profile, "budget", "maxBudget", "max_budget"),
    }
    return request.model_copy(update=updates)


def _load_recipe_candidates(request: RecommendationRequest) -> list[RecipeDocument]:
    service_documents = _search_recipe_service(request)
    if service_documents:
        return service_documents
    return model_loader.load_recipe_corpus()


def _run_hybrid_rag(request: RecommendationRequest, candidates: list[RecipeDocument]) -> list[RecipeDocument]:
    if not candidates:
        return []
    return HybridSearch(candidates).search(request, top_k=settings.top_k)


def _search_recipe_service(request: RecommendationRequest) -> list[RecipeDocument]:
    try:
        return recipe_service_client.search_recipe_documents(
            query=request.query,
            max_calories=request.max_calories,
            diet_type=normalize_diet_type(request.diet),
            excluded_allergen_ids=_excluded_allergen_ids(request),
            size=max(settings.top_k * 4, 20),
        )
    except RuntimeError as exc:
        logger.warning("Falling back to local recipe corpus because Recipe Service search failed: %s", exc)
        return []


def _excluded_allergen_ids(request: RecommendationRequest) -> list[int]:
    ids: list[int] = []
    for allergy in request.allergies:
        value = allergy.strip().lower()
        if not value.startswith("allergen:"):
            continue
        try:
            ids.append(int(value.split(":", 1)[1]))
        except ValueError:
            continue
    return ids


def _build_explanation(recommendations: list, warnings: list[str]) -> str:
    if not recommendations:
        return "Chua tim thay meal plan phu hop sau khi loc di ung, diet va dinh duong."
    names = ", ".join(item.name for item in recommendations[:3])
    warning_note = f" Co {len(warnings)} canh bao da duoc xu ly boi rule engine." if warnings else ""
    return f"Meal plan uu tien {names} dua tren FoodyLLM JSON scoring va toi uu dinh duong.{warning_note}"


def _dict_value(payload: dict[str, Any], *keys: str) -> dict[str, Any]:
    for key in keys:
        value = payload.get(key)
        if isinstance(value, dict):
            return value
    return {}


def _string_value(payload: dict[str, Any], *keys: str) -> str | None:
    for key in keys:
        value = payload.get(key)
        if value:
            return str(value)
    return None


def _string_list_value(payload: dict[str, Any], *keys: str) -> list[str]:
    for key in keys:
        value = payload.get(key)
        if isinstance(value, list):
            return [str(item) for item in value if item is not None]
        if isinstance(value, str) and value.strip():
            return [value.strip()]
    return []


def _list_value(payload: dict[str, Any], *keys: str) -> list[Any]:
    for key in keys:
        value = payload.get(key)
        if isinstance(value, list):
            return value
    return []


def _first_diet_preference(user_profile: dict[str, Any]) -> str | None:
    for item in _list_value(user_profile, "dietPreferences", "diet_preferences"):
        if not isinstance(item, dict):
            continue
        diet_type = _string_value(item, "dietType", "diet_type")
        if diet_type:
            return diet_type
    return _string_value(user_profile, "diet", "dietType", "diet_type")


def _allergy_tokens(user_profile: dict[str, Any]) -> list[str]:
    tokens: list[str] = []
    tokens.extend(_string_list_value(user_profile, "allergenNames", "allergen_names"))
    tokens.extend(
        item if item.lower().startswith("allergen:") else f"allergen:{item}"
        for item in _string_list_value(user_profile, "allergenIds", "allergen_ids")
    )

    for allergy in _list_value(user_profile, "allergies"):
        if not isinstance(allergy, dict):
            continue
        allergy_id = _string_value(allergy, "allergenId", "allergen_id")
        if allergy_id:
            tokens.append(f"allergen:{allergy_id}")

    return tokens


def _per_meal_int(
    payload: dict[str, Any],
    key: str,
    meals_per_day: int = 3,
    multiplier: float = 1.0,
    minimum: int = 1,
) -> int | None:
    value = _int_value(payload, key)
    if value is None:
        return None
    return max(minimum, round((value / meals_per_day) * multiplier))


def _int_value(payload: dict[str, Any], *keys: str) -> int | None:
    for key in keys:
        try:
            value = payload.get(key)
            if value is not None:
                return int(value)
        except (TypeError, ValueError):
            continue
    return None


def _unique(values: list[str]) -> list[str]:
    seen: set[str] = set()
    unique_values: list[str] = []
    for value in values:
        normalized = value.strip().lower()
        if not normalized or normalized in seen:
            continue
        seen.add(normalized)
        unique_values.append(value.strip())
    return unique_values
