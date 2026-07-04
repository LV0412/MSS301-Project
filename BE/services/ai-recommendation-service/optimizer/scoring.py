from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from dto.request import RecommendationRequest
from rag.vector_store import RecipeDocument


WEIGHTS = {
    "calories": 0.30,
    "goal": 0.20,
    "diet": 0.15,
    "protein": 0.15,
    "budget": 0.10,
    "cooking_time": 0.05,
    "meal_type": 0.05,
}

MAX_COMPONENT_SCORE = 100.0
DEFAULT_TARGET_CALORIES = 500
MAX_REASONABLE_PROTEIN = 50
FAST_COOKING_MINUTES = 15
SLOW_COOKING_MINUTES = 45


@dataclass(frozen=True)
class ScoreResult:
    score: float
    breakdown: dict[str, float]


def score_recipe(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    return calculate_score(recipe, request).score


def build_score_breakdown(recipe: RecipeDocument, request: RecommendationRequest) -> dict[str, float]:
    return calculate_score(recipe, request).breakdown


def calculate_score(recipe: RecipeDocument, request: RecommendationRequest) -> ScoreResult:
    if _has_allergy_conflict(recipe, request):
        return ScoreResult(score=0.0, breakdown={"allergy_conflict": 0.0, "total": 0.0})

    component_scores = {
        "calories": _score_calories(recipe, request),
        "goal": _score_goal(recipe, request),
        "diet": _score_diet(recipe, request),
        "protein": _score_protein(recipe, request),
        "budget": _score_budget(recipe, request),
        "cooking_time": _score_cooking_time(recipe),
        "meal_type": _score_meal_type(recipe, request),
    }

    weighted_scores = {
        name: round(component_scores[name] * WEIGHTS[name], 2)
        for name in component_scores
    }
    total = round(sum(weighted_scores.values()), 2)
    weighted_scores["total"] = total

    return ScoreResult(score=total, breakdown=weighted_scores)


def _score_calories(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    target = request.target_calories or request.max_calories or DEFAULT_TARGET_CALORIES
    difference_ratio = abs(recipe.calories - target) / max(target, 1)
    return _clamp(MAX_COMPONENT_SCORE * (1 - difference_ratio))


def _score_goal(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    goal = _normalize(request.goal)
    tags = _normalized_tags(recipe)

    if goal == "weight_loss":
        tag_score = 70 if "low_calorie" in tags or "weight_loss" in tags else 35
        calorie_bonus = 30 if recipe.calories <= 400 else 15 if recipe.calories <= 550 else 0
        return _clamp(tag_score + calorie_bonus)

    if goal == "muscle_gain":
        tag_score = 55 if "muscle_gain" in tags else 35 if "high_protein" in tags else 10
        protein_bonus = min(recipe.protein / MAX_REASONABLE_PROTEIN, 1.0) * 45
        return _clamp(tag_score + protein_bonus)

    if goal == "healthy":
        balanced_bonus = 45 if "balanced" in tags else 20
        macro_bonus = _score_macro_balance(recipe) * 0.55
        return _clamp(balanced_bonus + macro_bonus)

    return 70 if "balanced" in tags else 50


def _score_diet(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    diet = _normalize(request.diet)
    if not diet:
        return 70

    tags = _normalized_tags(recipe)
    if diet in tags:
        return MAX_COMPONENT_SCORE

    # Vegan recipes also satisfy vegetarian preference.
    if diet == "vegetarian" and "vegan" in tags:
        return 90

    return 20


def _score_protein(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    goal = _normalize(request.goal)
    target = 45 if goal == "muscle_gain" else 30
    return _clamp((recipe.protein / target) * MAX_COMPONENT_SCORE)


def _score_budget(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    if not request.budget:
        return 70

    if recipe.estimated_cost > request.budget:
        over_ratio = (recipe.estimated_cost - request.budget) / request.budget
        return _clamp(25 - over_ratio * 100)

    under_ratio = (request.budget - recipe.estimated_cost) / request.budget
    return _clamp(75 + under_ratio * 25)


def _score_cooking_time(recipe: RecipeDocument) -> float:
    cooking_time = _metadata_int(recipe, "cooking_time", SLOW_COOKING_MINUTES)
    if cooking_time <= FAST_COOKING_MINUTES:
        return MAX_COMPONENT_SCORE
    if cooking_time >= SLOW_COOKING_MINUTES:
        return 30

    span = SLOW_COOKING_MINUTES - FAST_COOKING_MINUTES
    return _clamp(MAX_COMPONENT_SCORE - ((cooking_time - FAST_COOKING_MINUTES) / span) * 70)


def _score_meal_type(recipe: RecipeDocument, request: RecommendationRequest) -> float:
    requested_meal_type = _normalize(getattr(request, "meal_type", None))
    if not requested_meal_type:
        return 70

    recipe_meal_type = _normalize(recipe.metadata.get("meal_type"))
    return MAX_COMPONENT_SCORE if recipe_meal_type == requested_meal_type else 20


def _score_macro_balance(recipe: RecipeDocument) -> float:
    carbs = _metadata_int(recipe, "carbs", 0)
    fat = _metadata_int(recipe, "fat", 0)
    total_macro = recipe.protein + carbs + fat
    if total_macro <= 0:
        return 40

    protein_ratio = recipe.protein / total_macro
    carbs_ratio = carbs / total_macro
    fat_ratio = fat / total_macro

    protein_score = 1 - abs(protein_ratio - 0.30) / 0.30
    carbs_score = 1 - abs(carbs_ratio - 0.45) / 0.45
    fat_score = 1 - abs(fat_ratio - 0.25) / 0.25
    return _clamp(((protein_score + carbs_score + fat_score) / 3) * MAX_COMPONENT_SCORE)


def _has_allergy_conflict(recipe: RecipeDocument, request: RecommendationRequest) -> bool:
    requested_allergies = {_normalize(allergy) for allergy in request.allergies}
    if not requested_allergies:
        return False

    recipe_allergens = {_normalize(allergen) for allergen in _metadata_list(recipe, "allergens")}
    if requested_allergies.intersection(recipe_allergens):
        return True

    recipe_text = f"{recipe.name} {recipe.text} {' '.join(recipe.tags)}".lower()
    return any(allergy and allergy in recipe_text for allergy in requested_allergies)


def _normalized_tags(recipe: RecipeDocument) -> set[str]:
    return {_normalize(tag) for tag in recipe.tags}


def _metadata_list(recipe: RecipeDocument, key: str) -> list[Any]:
    value = recipe.metadata.get(key, [])
    return value if isinstance(value, list) else []


def _metadata_int(recipe: RecipeDocument, key: str, default: int) -> int:
    value = recipe.metadata.get(key, default)
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _normalize(value: Any) -> str:
    return str(value or "").strip().lower()


def _clamp(value: float, minimum: float = 0.0, maximum: float = MAX_COMPONENT_SCORE) -> float:
    return max(minimum, min(maximum, value))
