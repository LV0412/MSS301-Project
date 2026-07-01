from pydantic import BaseModel


class RecommendedItem(BaseModel):
    recipe_id: str
    name: str
    calories: int
    protein: int
    estimated_cost: int
    tags: list[str]


class RecommendationResponse(BaseModel):
    query: str
    recommendations: list[RecommendedItem]
    explanation: str
    stages: list[str]
