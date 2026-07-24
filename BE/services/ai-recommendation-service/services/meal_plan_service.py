from datetime import date, time
from typing import Any

from fastapi import HTTPException

import api.recommendation as recommendation_api
from dto.meal_plan import GeneratedMealPlanEntry, GeneratedMealPlanResponse
from dto.request import RecommendationRequest
from optimizer.genetic import MealOptimizer


SLOTS: tuple[tuple[str, time, float], ...] = (
    ("breakfast", time(7, 0), 0.25),
    ("lunch", time(12, 0), 0.35),
    ("dinner", time(18, 30), 0.30),
    ("snack", time(15, 30), 0.10),
)


def generate_meal_plan(user_id: int, plan_date: date, recent_recipe_ids: list[int] | None = None) -> GeneratedMealPlanResponse:
    user_profile = _require_configured_profile(user_id)
    nutrition_goal = _nutrition_goal(user_profile)
    selected_items = []
    warnings: list[str] = []
    recent_ids = {str(recipe_id) for recipe_id in recent_recipe_ids or []}

    used_recipe_ids: set[str] = set()
    for meal_type, scheduled_time, ratio in SLOTS:
        request = _slot_request(user_id, meal_type, nutrition_goal, ratio)
        target_calories = request.target_calories
        item, slot_warnings = _select_slot_recipe(request, user_profile, used_recipe_ids, recent_ids)
        warnings.extend([f"{meal_type}: {warning}" for warning in slot_warnings])
        if item is None:
            warnings.append(f"Thieu slot {meal_type}: khong tim thay mon phu hop hard constraints.")
            continue
        used_recipe_ids.add(item.recipe_id)
        selected_items.append(_to_entry(meal_type, scheduled_time, item, target_calories, manually_swapped=False))

    if not selected_items:
        raise HTTPException(status_code=422, detail="Khong the tao meal plan vi khong co mon nao phu hop.")
    warnings.extend(_daily_warnings(selected_items, nutrition_goal))

    return GeneratedMealPlanResponse(
        user_id=user_id,
        plan_date=plan_date,
        title=f"Meal plan {plan_date.isoformat()}",
        status="DRAFT",
        nutrition_goal_id=_goal_id_or_none(nutrition_goal),
        match_score=_daily_match_score(selected_items, nutrition_goal),
        warnings=_unique(warnings),
        entries=selected_items,
    )


def build_swap_candidate(user_id: int, meal_type: str, new_recipe_id: int) -> GeneratedMealPlanEntry:
    user_profile = _require_configured_profile(user_id)
    nutrition_goal = _nutrition_goal(user_profile)
    ratio = next((slot_ratio for slot, _time, slot_ratio in SLOTS if slot == meal_type), 1 / 3)
    scheduled_time = next((slot_time for slot, slot_time, _ratio in SLOTS if slot == meal_type), time(12, 0))
    request = _slot_request(user_id, meal_type, nutrition_goal, ratio)
    recipe = recommendation_api.recipe_service_client.get_recipe_document(new_recipe_id)
    enriched_request = recommendation_api._merge_profile(request, user_profile).model_copy(
        update={
            "max_calories": None,
            "min_protein": None,
            "max_carbs": None,
            "max_fat": None,
            "budget": None,
        }
    )
    rule_result = recommendation_api.rule_engine.filter([recipe], enriched_request, user_profile)
    if not rule_result.candidates:
        raise HTTPException(
            status_code=422,
            detail={"message": "Recipe violates hard constraints.", "warnings": rule_result.warnings},
        )
    if _recipe_meal_type(recipe) and _recipe_meal_type(recipe) != meal_type:
        raise HTTPException(
            status_code=422,
            detail={"message": f"Recipe is for {_recipe_meal_type(recipe)}, not {meal_type}."},
        )
    item = MealOptimizer().optimize([recipe], enriched_request, llm_scores=[])[0]
    return _to_entry(meal_type, scheduled_time, item, enriched_request.target_calories, manually_swapped=True)


def _select_slot_recipe(
    request: RecommendationRequest,
    user_profile: dict[str, Any],
    used_recipe_ids: set[str],
    recent_recipe_ids: set[str],
):
    enriched_request = recommendation_api._merge_profile(request, user_profile).model_copy(
        update={
            "max_calories": None,
            "min_protein": None,
            "max_carbs": None,
            "max_fat": None,
            "budget": None,
        }
    )
    candidates = recommendation_api._load_recipe_candidates(enriched_request)
    rule_result = recommendation_api.rule_engine.filter(candidates, enriched_request, user_profile)
    warnings = list(rule_result.warnings)
    candidates = [candidate for candidate in rule_result.candidates if candidate.recipe_id not in used_recipe_ids]
    if not candidates:
        return None, warnings

    meal_type_candidates = [candidate for candidate in candidates if _recipe_meal_type(candidate) == request.meal_type]
    if meal_type_candidates:
        candidates = meal_type_candidates
    else:
        warnings.append(f"Khong co mon dung loai bua {request.meal_type}; cho phep chon mon khac bua.")

    without_recent = [candidate for candidate in candidates if candidate.recipe_id not in recent_recipe_ids]
    if without_recent:
        candidates = without_recent
    else:
        warnings.append("Khong du lua chon moi nen cho phep lap mon trong 3 ngay gan nhat.")

    target = enriched_request.target_calories
    if target is None:
        chosen = min(candidates, key=lambda candidate: candidate.calories)
        return _to_greedy_item(chosen, enriched_request), warnings

    for tolerance in (0.15, 0.30, 0.50):
        lower = target * (1 - tolerance)
        upper = target * (1 + tolerance)
        tolerated = [candidate for candidate in candidates if lower <= candidate.calories <= upper]
        if tolerated:
            chosen = min(tolerated, key=lambda candidate: abs(candidate.calories - target))
            if tolerance > 0.15:
                warnings.append(f"Noi dung sai calories {request.meal_type} len {round(tolerance * 100)}%.")
            return _to_greedy_item(chosen, enriched_request), warnings

    warnings.append(f"Khong co mon trong dung sai calories cho {request.meal_type}; chon mon gan target nhat.")
    chosen = min(candidates, key=lambda candidate: abs(candidate.calories - target))
    return _to_greedy_item(chosen, enriched_request), warnings


def _to_greedy_item(candidate, request: RecommendationRequest):
    return MealOptimizer().optimize([candidate], request, llm_scores=[])[0]


def _recipe_meal_type(candidate) -> str:
    value = candidate.metadata.get("meal_type") if getattr(candidate, "metadata", None) else ""
    return str(value or "").strip().lower()


def _require_configured_profile(user_id: int) -> dict[str, Any]:
    user_profile = recommendation_api.user_service_client.get_ai_profile(str(user_id))
    if not user_profile:
        raise HTTPException(status_code=422, detail="Health profile and nutrition goal are required.")
    health_status = user_profile.get("healthProfileStatus") or user_profile.get("health_profile_status") or {}
    if str(health_status.get("status") or "").upper() != "COMPLETE":
        raise HTTPException(status_code=422, detail="Complete health profile is required before generating a meal plan.")
    nutrition_goal = _nutrition_goal(user_profile)
    goal_configured = nutrition_goal.get("goalConfigured", nutrition_goal.get("goal_configured"))
    if not nutrition_goal or goal_configured is False:
        raise HTTPException(status_code=422, detail="Nutrition goal must be configured before generating a meal plan.")
    return user_profile


def _slot_request(user_id: int, meal_type: str, nutrition_goal: dict[str, Any], ratio: float) -> RecommendationRequest:
    return RecommendationRequest(
        user_id=str(user_id),
        query=f"goi y {meal_type} phu hop nutrition goal",
        meal_type=meal_type,
        goal=_string_value(nutrition_goal, "goalType", "goal_type"),
        target_calories=_ratio_int(nutrition_goal, "calories", ratio),
        limit=8,
    )


def _to_entry(
    meal_type: str,
    scheduled_time: time,
    item,
    target_calories: int | None,
    manually_swapped: bool,
) -> GeneratedMealPlanEntry:
    return GeneratedMealPlanEntry(
        recipe_id=int(item.recipe_id),
        meal_type=meal_type,
        scheduled_time=scheduled_time,
        recipe_name=item.name,
        target_calories_for_slot=target_calories,
        actual_calories=item.calories,
        actual_protein=item.protein,
        actual_carbs=item.carbs,
        actual_fat=item.fat,
        image_url=item.image_url,
        suitability_score=round(item.suitability_score, 2),
        reason=item.reason,
        warnings=item.warnings,
        is_manually_swapped=manually_swapped,
    )


def _daily_match_score(items: list[GeneratedMealPlanEntry], nutrition_goal: dict[str, Any]) -> float:
    scores = [
        _macro_score(sum(item.actual_calories for item in items), _int_value(nutrition_goal, "calories", "dailyCaloriesGoal")),
        _macro_score(sum(item.actual_protein for item in items), _int_value(nutrition_goal, "protein"), absolute_tolerance=5),
        _macro_score(sum(item.actual_carbs for item in items), _int_value(nutrition_goal, "carbs"), absolute_tolerance=5),
        _macro_score(sum(item.actual_fat for item in items), _int_value(nutrition_goal, "fat"), absolute_tolerance=5),
    ]
    return round(sum(scores) / len(scores), 2)


def _daily_warnings(items: list[GeneratedMealPlanEntry], nutrition_goal: dict[str, Any]) -> list[str]:
    warnings: list[str] = []
    target_calories = _int_value(nutrition_goal, "calories", "dailyCaloriesGoal")
    actual_calories = sum(item.actual_calories for item in items)
    if target_calories:
        difference_ratio = abs(actual_calories - target_calories) / target_calories
        if difference_ratio > 0.30:
            warnings.append("Tong calories lech hon 30% so voi Nutrition Goal.")
        elif difference_ratio > 0.10:
            warnings.append("Tong calories nam ngoai dung sai 10% so voi Nutrition Goal.")

    for label, actual, target in (
        ("protein", sum(item.actual_protein for item in items), _int_value(nutrition_goal, "protein")),
        ("carbs", sum(item.actual_carbs for item in items), _int_value(nutrition_goal, "carbs")),
        ("fat", sum(item.actual_fat for item in items), _int_value(nutrition_goal, "fat")),
    ):
        if target and abs(actual - target) > 5:
            warnings.append(f"Tong {label} lech hon 5g so voi Nutrition Goal.")
    return warnings


def _macro_score(actual: int, target: int | None, absolute_tolerance: int = 0) -> float:
    if not target:
        return 100.0
    difference = max(0, abs(actual - target) - absolute_tolerance)
    return max(0.0, 100 - difference / target * 100)


def _nutrition_goal(user_profile: dict[str, Any]) -> dict[str, Any]:
    value = user_profile.get("nutritionGoal") or user_profile.get("nutrition_goal")
    return value if isinstance(value, dict) else {}


def _goal_id_or_none(nutrition_goal: dict[str, Any]) -> int | None:
    return _int_value(nutrition_goal, "goalId", "goal_id", "nutritionGoalId", "nutrition_goal_id")


def _ratio_int(payload: dict[str, Any], key: str, ratio: float, minimum: int = 1) -> int | None:
    value = _int_value(payload, key, "dailyCaloriesGoal" if key == "calories" else key)
    return max(minimum, round(value * ratio)) if value is not None else None


def _int_value(payload: dict[str, Any], *keys: str) -> int | None:
    for key in keys:
        try:
            value = payload.get(key)
            if value is not None:
                return round(float(value))
        except (TypeError, ValueError):
            continue
    return None


def _string_value(payload: dict[str, Any], *keys: str) -> str | None:
    for key in keys:
        value = payload.get(key)
        if value:
            return str(value)
    return None


def _unique(values: list[str]) -> list[str]:
    return list(dict.fromkeys(value for value in values if value))
