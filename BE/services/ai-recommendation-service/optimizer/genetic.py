from dto.request import RecommendationRequest
from dto.response import RecommendedItem
from rag.vector_store import RecipeDocument


class MealOptimizer:
    """Keeps retrieval relevance first, then applies light nutrition tie-breakers."""

    def optimize(
        self,
        candidates: list[RecipeDocument],
        request: RecommendationRequest,
        llm_scores: list[dict] | None = None,
    ) -> list[RecommendedItem]:
        scores_by_recipe = {
            str(item.get("recipe_id")): item
            for item in llm_scores or []
            if item.get("recipe_id") is not None
        }
        ranked_candidates = sorted(
            enumerate(candidates),
            key=lambda item: self._optimization_score(item[0], item[1], request, scores_by_recipe),
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
                suitability_score=self._llm_score(item, scores_by_recipe),
                reason=str(scores_by_recipe.get(item.recipe_id, {}).get("reason") or ""),
                warnings=self._llm_warnings(item, scores_by_recipe),
            )
            for _index, item in ranked_candidates
        ]

    def _optimization_score(
        self,
        relevance_rank: int,
        candidate: RecipeDocument,
        request: RecommendationRequest,
        scores_by_recipe: dict[str, dict],
    ) -> float:
        relevance_score = 1000 - (relevance_rank * 100)
        calorie_score = self._calorie_score(candidate, request)
        protein_score = min(candidate.protein, 50) * 0.5
        budget_score = self._budget_score(candidate, request)
        llm_score = self._llm_score(candidate, scores_by_recipe) * 3
        return relevance_score + llm_score + calorie_score + protein_score + budget_score

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

    def _llm_score(self, candidate: RecipeDocument, scores_by_recipe: dict[str, dict]) -> float:
        try:
            return float(scores_by_recipe.get(candidate.recipe_id, {}).get("suitability_score", 0.0))
        except (TypeError, ValueError):
            return 0.0

    def _llm_warnings(self, candidate: RecipeDocument, scores_by_recipe: dict[str, dict]) -> list[str]:
        warnings = scores_by_recipe.get(candidate.recipe_id, {}).get("warnings", [])
        if not isinstance(warnings, list):
            return []
        return [str(warning) for warning in warnings]
