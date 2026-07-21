import logging
from typing import Any

from fastapi import APIRouter, HTTPException

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
from services.suggestion_service import save_suggestion


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
def recommend(request: RecommendationRequest) -> RecommendationResponse:
    user_profile = _load_user_profile(request)
    enriched_request = _merge_profile(request, user_profile)
    enriched_request = _resolve_available_ingredients(enriched_request)
    recipe_candidates = _load_recipe_candidates(enriched_request)
    rule_result = rule_engine.filter(recipe_candidates, enriched_request, user_profile)
    top_k_candidates = _run_hybrid_rag(enriched_request, rule_result.candidates)
    prompt = prompt_builder.build(enriched_request, top_k_candidates, user_profile, rule_result.warnings)
    try:
        llm_scores = llm.score_recipes(prompt, top_k_candidates, enriched_request, rule_result.warnings)
    except RuntimeError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    optimized_items = optimizer.optimize(top_k_candidates, enriched_request, llm_scores)
    llm_info = llm.runtime_info()
    warnings = list(rule_result.warnings)
    if llm_info["mode"] != "foodyllm" and llm_info["fallback_reason"]:
        warnings.append(f"FoodyLLM fallback: {llm_info['fallback_reason']}")
    suggestion_id = _persist_recommendation(enriched_request, optimized_items, warnings)

    return RecommendationResponse(
        query=enriched_request.query,
        recommendations=optimized_items,
        explanation=_build_explanation(optimized_items, warnings, str(llm_info["mode"])),
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
        user_profile_applied=user_profile is not None,
        llm_provider=str(llm_info["provider"]),
        llm_mode=str(llm_info["mode"]),
        suggestion_id=suggestion_id,
        warnings=warnings,
    )


def _load_user_profile(request: RecommendationRequest) -> dict[str, Any] | None:
    if not request.user_id or not request.use_user_profile:
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
        "target_calories": request.target_calories or _per_meal_int(nutrition_goal, "calories", request.meal_type),
        "max_calories": request.max_calories or _per_meal_int(
            nutrition_goal, "calories", request.meal_type, multiplier=1.25
        ),
        "min_protein": request.min_protein or _per_meal_int(
            nutrition_goal, "protein", request.meal_type, minimum=0
        ),
        "max_carbs": request.max_carbs or _per_meal_int(
            nutrition_goal, "carbs", request.meal_type, minimum=0
        ),
        "max_fat": request.max_fat or _per_meal_int(nutrition_goal, "fat", request.meal_type, minimum=0),
        "budget": request.budget or _int_value(user_profile, "budget", "maxBudget", "max_budget"),
    }
    return request.model_copy(update=updates)


def _load_recipe_candidates(request: RecommendationRequest) -> list[RecipeDocument]:
    service_documents = _search_recipe_service(request)
    if service_documents:
        return service_documents
    try:
        snapshot_documents = recipe_service_client.get_catalog_snapshot_documents()
        if snapshot_documents:
            return snapshot_documents
    except RuntimeError as exc:
        logger.warning("Recipe Service snapshot unavailable: %s", exc)
    return model_loader.load_recipe_corpus()


def _run_hybrid_rag(request: RecommendationRequest, candidates: list[RecipeDocument]) -> list[RecipeDocument]:
    if not candidates:
        return []
    return HybridSearch(candidates).search(request, top_k=request.limit)


def _resolve_available_ingredients(request: RecommendationRequest) -> RecommendationRequest:
    if not request.available_ingredients:
        return request
    try:
        resolved = recipe_service_client.resolve_ingredient_ids(request.available_ingredients)
    except RuntimeError as exc:
        logger.warning("Could not resolve ingredient names through Recipe Service: %s", exc)
        return request
    return request.model_copy(update={"ingredient_ids": sorted(set([*request.ingredient_ids, *resolved]))})


def _search_recipe_service(request: RecommendationRequest) -> list[RecipeDocument]:
    try:
        return recipe_service_client.search_recipe_documents(
            query=None if request.ingredient_ids else request.query,
            max_calories=request.max_calories,
            diet_type=normalize_diet_type(request.diet),
            excluded_allergen_ids=_excluded_allergen_ids(request),
            ingredient_ids=request.ingredient_ids,
            size=max(request.limit * 4, 20),
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


def _build_explanation(recommendations: list, warnings: list[str], llm_mode: str) -> str:
    if not recommendations:
        return "Chưa tìm thấy món phù hợp sau khi lọc dị ứng, chế độ ăn, dinh dưỡng và nguyên liệu."
    names = ", ".join(item.name for item in recommendations[:3])
    warning_note = f" Có {len(warnings)} cảnh báo kèm theo." if warnings else ""
    scorer = "FoodyLLM" if llm_mode == "foodyllm" else "bộ chấm điểm dự phòng"
    return f"Hệ thống ưu tiên {names} dựa trên hồ sơ người dùng, nguyên liệu và {scorer}.{warning_note}"


def _persist_recommendation(
    request: RecommendationRequest,
    recommendations: list,
    warnings: list[str],
) -> int | None:
    if not settings.persist_recommendations or not request.user_id or not recommendations:
        return None
    try:
        return save_suggestion(int(request.user_id), settings.foody_adapter, recommendations)
    except (RuntimeError, ValueError) as exc:
        logger.exception("Could not persist recommendation: %s", exc)
        warnings.append("Không thể lưu lịch sử recommendation.")
        return None


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
    meal_type: str | None = None,
    multiplier: float = 1.0,
    minimum: int = 1,
) -> int | None:
    value = _int_value(payload, *keys)
    if value is None:
        return None
    ratios = {"breakfast": 0.25, "lunch": 0.35, "dinner": 0.30, "snack": 0.10}
    ratio = ratios.get((meal_type or "").strip().lower(), 1 / 3)
    return max(minimum, round(value * ratio * multiplier))


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
