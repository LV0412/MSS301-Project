from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class RecommendationRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "examples": [
                {
                    "query": "goi y bua trua giau dam duoi 600 kcal",
                    "user_id": "1",
                    "available_ingredients": ["ức gà", "cà chua", "gạo lứt"],
                    "ingredient_ids": [2, 3],
                    "meal_type": "lunch",
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

    query: str = Field(
        default="Gợi ý món ăn phù hợp với hồ sơ và nguyên liệu hiện có",
        min_length=2,
        description="Natural-language food recommendation intent.",
    )
    user_id: str | None = Field(
        default=None,
        pattern=r"^[1-9]\d*$",
        description="Positive numeric User Service ID used for profile enrichment and persistence.",
    )
    available_ingredients: list[str] = Field(
        default_factory=list,
        max_length=50,
        description="Ingredient names currently available to the user.",
    )
    ingredient_ids: list[int] = Field(
        default_factory=list,
        max_length=50,
        description="Recipe Service ingredient IDs currently available to the user.",
    )
    meal_type: Literal["breakfast", "lunch", "dinner", "snack"] | None = None
    diet: str | None = Field(default=None, description="Diet preference, for example vegetarian, vegan, keto.")
    goal: str | None = Field(default=None, description="Nutrition goal, for example weight_loss, muscle_gain, healthy.")
    allergies: list[str] = Field(default_factory=list, description="Allergy names or allergen:id tokens.")
    max_calories: int | None = Field(default=None, ge=1, description="Maximum calories allowed per recommended recipe.")
    target_calories: int | None = Field(default=None, ge=1, description="Preferred calories per recommended recipe.")
    min_protein: int | None = Field(default=None, ge=0, description="Minimum protein grams preferred per recipe.")
    max_carbs: int | None = Field(default=None, ge=0, description="Maximum carbs grams allowed per recipe.")
    max_fat: int | None = Field(default=None, ge=0, description="Maximum fat grams allowed per recipe.")
    budget: int | None = Field(default=None, ge=1, description="Maximum estimated recipe cost in VND.")
    strict_ingredients: bool = Field(default=False, description="Require every recipe ingredient to be available.")
    use_user_profile: bool = Field(default=True, description="Enrich missing constraints from User Service.")
    limit: int = Field(default=5, ge=1, le=20, description="Maximum number of recipes returned.")

    @field_validator("available_ingredients")
    @classmethod
    def normalize_available_ingredients(cls, values: list[str]) -> list[str]:
        normalized = [value.strip() for value in values if value.strip()]
        return list(dict.fromkeys(normalized))

    @field_validator("ingredient_ids")
    @classmethod
    def validate_ingredient_ids(cls, values: list[int]) -> list[int]:
        if any(value <= 0 for value in values):
            raise ValueError("ingredient_ids must contain only positive IDs")
        return sorted(set(values))
