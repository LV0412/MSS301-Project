from dto.request import RecommendationRequest
from dto.response import RecommendedItem
from rag.vector_store import RecipeDocument


class MealOptimizer:
    """Keeps retrieval relevance first, then applies light nutrition tie-breakers."""

    def optimize(
        self,
        candidates: list[RecipeDocument],
        request: RecommendationRequest,
    ) -> list[RecommendedItem]:
        ranked_candidates = sorted(
            enumerate(candidates),
            key=lambda item: self._optimization_score(item[0], item[1], request),
            reverse=True,
        )
        return [
            RecommendedItem(
                recipe_id=item.recipe_id,
                name=item.name,
                calories=item.calories,
                protein=item.protein,
                estimated_cost=item.estimated_cost,
                tags=item.tags,
            )
            for _index, item in ranked_candidates
        ]

    def _optimization_score(
        self,
        relevance_rank: int,
        candidate: RecipeDocument,
        request: RecommendationRequest,
    ) -> float:
        relevance_score = 1000 - (relevance_rank * 100)
        calorie_score = self._calorie_score(candidate, request)
        protein_score = min(candidate.protein, 50) * 0.5
        budget_score = self._budget_score(candidate, request)
        return relevance_score + calorie_score + protein_score + budget_score

    def _calorie_score(self, candidate: RecipeDocument, request: RecommendationRequest) -> float:
        target = request.target_calories or request.max_calories
        if target is None:
            return 0.0
        difference = abs(target - candidate.calories)
        return max(0.0, 100 - (difference / max(target, 1) * 100))

    def _budget_score(self, candidate: RecipeDocument, request: RecommendationRequest) -> float:
        if request.budget is None:
            return 0.0
        if candidate.estimated_cost > request.budget:
            return -50.0
        return min(30.0, (request.budget - candidate.estimated_cost) / max(request.budget, 1) * 30)
