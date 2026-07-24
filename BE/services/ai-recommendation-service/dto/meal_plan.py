from datetime import date, time

from pydantic import BaseModel, ConfigDict, Field


class SwapMealPlanEntryRequest(BaseModel):
    new_recipe_id: int = Field(alias="newRecipeId", gt=0)


class GeneratedMealPlanEntry(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    recipe_id: int
    meal_type: str
    scheduled_time: time
    recipe_name: str
    target_calories_for_slot: int | None = None
    actual_calories: int
    actual_protein: int
    actual_carbs: int
    actual_fat: int
    image_url: str | None = None
    suitability_score: float
    reason: str | None = None
    warnings: list[str] = Field(default_factory=list)
    is_manually_swapped: bool


class GeneratedMealPlanResponse(BaseModel):
    user_id: int
    plan_date: date
    title: str
    status: str
    nutrition_goal_id: int | None = None
    match_score: float
    warnings: list[str] = Field(default_factory=list)
    entries: list[GeneratedMealPlanEntry] = Field(default_factory=list)
