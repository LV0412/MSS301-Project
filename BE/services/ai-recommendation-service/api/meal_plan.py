from datetime import date

from fastapi import APIRouter, Body, Header, Query

from dto.meal_plan import GeneratedMealPlanEntry, GeneratedMealPlanResponse, GenerateMealPlanRequest
from services.meal_plan_service import build_swap_candidate, generate_meal_plan


router = APIRouter(prefix="/internal/meal-plans")


@router.post(
    "/generate",
    response_model=GeneratedMealPlanResponse,
    summary="Generate a draft meal plan candidate for User Service persistence",
)
def generate(
    date_: date = Query(alias="date"),
    request: GenerateMealPlanRequest = Body(default_factory=GenerateMealPlanRequest),
    user_id: int = Header(alias="X-User-Id", gt=0),
) -> GeneratedMealPlanResponse:
    return generate_meal_plan(user_id=user_id, plan_date=date_, recent_recipe_ids=request.recent_recipe_ids)


@router.get(
    "/swap-candidate",
    response_model=GeneratedMealPlanEntry,
    summary="Validate and build one swap candidate for User Service persistence",
)
def swap_candidate(
    meal_type: str = Query(alias="mealType"),
    new_recipe_id: int = Query(alias="newRecipeId", gt=0),
    user_id: int = Header(alias="X-User-Id", gt=0),
) -> GeneratedMealPlanEntry:
    return build_swap_candidate(user_id=user_id, meal_type=meal_type, new_recipe_id=new_recipe_id)
