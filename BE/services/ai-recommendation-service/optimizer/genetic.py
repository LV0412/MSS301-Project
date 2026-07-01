from dto.request import RecommendationRequest
from dto.response import RecommendedItem
from rag.vector_store import RecipeDocument


class MealOptimizer:
    """Placeholder optimizer. Replace with a real genetic algorithm when datasets are ready."""

    def optimize(
        self,
        candidates: list[RecipeDocument],
        request: RecommendationRequest,
    ) -> list[RecommendedItem]:
        sorted_candidates = sorted(
            candidates,
            key=lambda item: (
                abs((request.target_calories or item.calories) - item.calories),
                -item.protein,
                item.estimated_cost,
            ),
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
            for item in sorted_candidates
        ]
