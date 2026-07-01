from dataclasses import dataclass, field

from rag.embedding import SimpleEmbedding, cosine_similarity


@dataclass(frozen=True)
class RecipeDocument:
    recipe_id: str
    name: str
    tags: list[str]
    calories: int
    protein: int
    estimated_cost: int
    text: str
    metadata: dict[str, str] = field(default_factory=dict)


class InMemoryVectorStore:
    def __init__(self, documents: list[RecipeDocument]) -> None:
        self.embedding = SimpleEmbedding()
        self.documents = documents
        self.document_vectors = {
            document.recipe_id: self.embedding.embed(self._document_text(document))
            for document in documents
        }

    def similarity_search(self, query: str, top_k: int) -> list[tuple[RecipeDocument, float]]:
        query_vector = self.embedding.embed(query)
        scored = [
            (document, cosine_similarity(query_vector, self.document_vectors[document.recipe_id]))
            for document in self.documents
        ]
        return sorted(scored, key=lambda item: item[1], reverse=True)[:top_k]

    def _document_text(self, document: RecipeDocument) -> str:
        return " ".join([document.name, document.text, *document.tags])
