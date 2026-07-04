import logging

from fastapi import APIRouter

from clients.recipe_service_client import RecipeServiceClient, normalize_diet_type
from config import settings
from dto.request import RecommendationRequest
from dto.response import RecommendationResponse
from llm.foodyllm import FoodyLLM
from models.model_loader import ModelLoader
from optimizer.genetic import MealOptimizer
from prompt.prompt_builder import PromptBuilder
from rag.hybrid_search import HybridSearch
from rag.vector_store import RecipeDocument


router = APIRouter()
logger = logging.getLogger(__name__)

model_loader = ModelLoader()
hybrid_search = HybridSearch(model_loader.load_recipe_corpus())
prompt_builder = PromptBuilder()
llm = FoodyLLM()
optimizer = MealOptimizer()
recipe_service_client = RecipeServiceClient()


@router.post(
    "/recommendations",
    response_model=RecommendationResponse,
    summary="Generate food recommendations",
    description=(
        "Search Recipe Service internal recipes first, fall back to the local recipe corpus, "
        "build a RAG prompt, generate a FoodyLLM explanation, and optimize meal candidates."
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
    candidates = _search_candidates(request)
    prompt = prompt_builder.build(request, candidates)
    explanation = llm.generate(prompt)
    optimized_items = optimizer.optimize(candidates, request)

    return RecommendationResponse(
        query=request.query,
        recommendations=optimized_items,
        explanation=explanation,
        stages=[
            "request_validation",
            "hybrid_search",
            "rag_prompt_builder",
            "foodyllm_generation",
            "meal_optimization",
        ],
    )


def _search_candidates(request: RecommendationRequest) -> list[RecipeDocument]:
    service_documents = _search_recipe_service(request)
    if service_documents:
        return HybridSearch(service_documents).search(request, top_k=settings.top_k)
    return hybrid_search.search(request, top_k=settings.top_k)


def _search_recipe_service(request: RecommendationRequest) -> list[RecipeDocument]:
    try:
        return recipe_service_client.search_recipe_documents(
            query=None,
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
