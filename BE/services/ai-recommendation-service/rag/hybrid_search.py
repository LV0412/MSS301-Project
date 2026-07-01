from dto.request import RecommendationRequest
from rag.vector_store import InMemoryVectorStore, RecipeDocument


class HybridSearch:
    def __init__(self, documents: list[RecipeDocument]) -> None:
        self.documents = documents
        self.vector_store = InMemoryVectorStore(documents)

    def search(self, request: RecommendationRequest, top_k: int) -> list[RecipeDocument]:
        semantic_results = self.vector_store.similarity_search(request.query, top_k=len(self.documents))
        filtered = [
            (document, score + self._keyword_score(document, request))
            for document, score in semantic_results
            if self._matches_constraints(document, request)
        ]
        ranked = sorted(filtered, key=lambda item: item[1], reverse=True)
        return [document for document, _score in ranked[:top_k]]

    def _keyword_score(self, document: RecipeDocument, request: RecommendationRequest) -> float:
        query_terms = set(request.query.lower().split())
        tag_hits = len(query_terms.intersection(document.tags))
        diet_hit = 1 if request.diet and request.diet.lower() in document.tags else 0
        return (tag_hits * 0.2) + (diet_hit * 0.5)

    def _matches_constraints(self, document: RecipeDocument, request: RecommendationRequest) -> bool:
        if request.max_calories and document.calories > request.max_calories:
            return False
        if request.budget and document.estimated_cost > request.budget:
            return False
        allergy_terms = {item.lower() for item in request.allergies}
        document_text = f"{document.name} {document.text} {' '.join(document.tags)}".lower()
        return not any(allergy in document_text for allergy in allergy_terms)
