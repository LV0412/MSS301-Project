from pydantic import BaseModel, Field


class RecommendationRequest(BaseModel):
    query: str = Field(..., min_length=2, examples=["high protein lunch under 600 calories"])
    user_id: str | None = Field(default=None, examples=["user-001"])
    diet: str | None = Field(default=None, examples=["vegetarian"])
    goal: str | None = Field(default=None, examples=["weight_loss"])
    allergies: list[str] = Field(default_factory=list, examples=[["peanut", "shrimp"]])
    max_calories: int | None = Field(default=None, ge=1, examples=[600])
    target_calories: int | None = Field(default=None, ge=1, examples=[500])
    budget: int | None = Field(default=None, ge=1, examples=[60000])
