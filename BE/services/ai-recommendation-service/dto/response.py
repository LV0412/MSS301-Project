from pydantic import BaseModel, ConfigDict, Field


class RecommendedItem(BaseModel):
    recipe_id: str = Field(description="Recipe identifier from Recipe Service or local fallback data.")
    name: str = Field(description="Recipe display name.")
    calories: int = Field(description="Calories per serving.")
    protein: int = Field(description="Protein grams per serving.")
    estimated_cost: int = Field(description="Estimated recipe cost in VND when available.")
    tags: list[str] = Field(description="Diet, allergen, or retrieval tags used during ranking.")
    suitability_score: float = Field(default=0.0, description="FoodyLLM suitability score from 0 to 100.")
    reason: str = Field(default="", description="FoodyLLM reason for choosing this recipe.")
    warnings: list[str] = Field(default_factory=list, description="Diet, allergy, or nutrition warnings.")


class RecommendationResponse(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "examples": [
                {
                    "query": "goi y bua trua giau dam duoi 600 kcal",
                    "recommendations": [
                        {
                            "recipe_id": "12",
                            "name": "Com ga ap chao",
                            "calories": 520,
                            "protein": 35,
                            "estimated_cost": 45000,
                            "tags": ["NORMAL", "high_protein"],
                            "suitability_score": 91.5,
                            "reason": "Phu hop muc tieu giau dam va nam trong gioi han calories.",
                            "warnings": [],
                        }
                    ],
                    "explanation": "He thong da ket hop hybrid search va RAG context de chon cac mon phu hop.",
                    "stages": [
                        "request_validation",
                        "hybrid_search",
                        "rag_prompt_builder",
                        "foodyllm_generation",
                        "meal_optimization",
                    ],
                }
            ]
        }
    )

    query: str = Field(description="Original recommendation query.")
    recommendations: list[RecommendedItem] = Field(description="Ranked recipe recommendations.")
    explanation: str = Field(description="FoodyLLM generated explanation.")
    stages: list[str] = Field(description="Pipeline stages executed for this recommendation.")
