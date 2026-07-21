from pydantic import BaseModel, ConfigDict, Field


class RecommendationRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "examples": [
                {
                    "query": "goi y bua trua giau dam duoi 600 kcal",
                    "user_id": "1",
                    "diet": "vegetarian",
                    "goal": "weight_loss",
                    "allergies": ["allergen:2", "peanut"],
                    "max_calories": 600,
                    "target_calories": 500,
                    "budget": 60000,
                }
            ]
        }
    )

    query: str = Field(..., min_length=2, description="Natural-language food recommendation intent.")
    user_id: str | None = Field(
        default=None,
        description="Deprecated. The service uses X-User-Id from the Gateway for profile enrichment.",
    )
    diet: str | None = Field(default=None, description="Diet preference, for example vegetarian, vegan, keto.")
    goal: str | None = Field(default=None, description="Nutrition goal, for example weight_loss, muscle_gain, healthy.")
    allergies: list[str] = Field(default_factory=list, description="Allergy names or allergen:id tokens.")
    max_calories: int | None = Field(default=None, ge=1, description="Maximum calories allowed per recommended recipe.")
    target_calories: int | None = Field(default=None, ge=1, description="Preferred calories per recommended recipe.")
    min_protein: int | None = Field(default=None, ge=0, description="Minimum protein grams preferred per recipe.")
    max_carbs: int | None = Field(default=None, ge=0, description="Maximum carbs grams allowed per recipe.")
    max_fat: int | None = Field(default=None, ge=0, description="Maximum fat grams allowed per recipe.")
    budget: int | None = Field(default=None, ge=1, description="Maximum estimated recipe cost in VND.")
