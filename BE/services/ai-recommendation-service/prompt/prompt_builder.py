from dto.request import RecommendationRequest
from rag.vector_store import RecipeDocument


class PromptBuilder:
    def build(self, request: RecommendationRequest, candidates: list[RecipeDocument]) -> str:
        context = "\n".join(
            f"- {item.name}: {item.calories} kcal, {item.protein}g protein, tags={', '.join(item.tags)}"
            for item in candidates
        )
        return (
            "You are FoodyLLM, a nutrition recommendation assistant.\n"
            f"User query: {request.query}\n"
            f"Diet: {request.diet or 'not specified'}\n"
            f"Goal: {request.goal or 'balanced recommendation'}\n"
            f"Retrieved recipes:\n{context or '- No matching recipe found'}\n"
            "Explain the recommendation in concise Vietnamese."
        )
