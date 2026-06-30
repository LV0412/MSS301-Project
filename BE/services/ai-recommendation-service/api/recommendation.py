from fastapi import APIRouter

from config import settings
from dto.request import RecommendationRequest
from dto.response import RecommendationResponse
from llm.foodyllm import FoodyLLM
from models.model_loader import ModelLoader
from optimizer.genetic import MealOptimizer
from prompt.prompt_builder import PromptBuilder
from rag.hybrid_search import HybridSearch


router = APIRouter()

model_loader = ModelLoader()
hybrid_search = HybridSearch(model_loader.load_recipe_corpus())
prompt_builder = PromptBuilder()
llm = FoodyLLM()
optimizer = MealOptimizer()


@router.post("/recommendations", response_model=RecommendationResponse)
def recommend(request: RecommendationRequest) -> RecommendationResponse:
    candidates = hybrid_search.search(request, top_k=settings.top_k)
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
