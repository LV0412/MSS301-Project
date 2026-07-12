from typing import Any

from config import settings
from dto.request import RecommendationRequest
from rag.vector_store import RecipeDocument


class PromptBuilder:
    def build(
        self,
        request: RecommendationRequest,
        candidates: list[RecipeDocument],
        user_profile: dict[str, Any] | None = None,
        rule_warnings: list[str] | None = None,
    ) -> str:
        context = "\n".join(
            (
                f"- id={item.recipe_id}; name={item.name}; {item.calories} kcal; "
                f"protein={item.protein}g; carbs={item.metadata.get('carbs', 0)}g; "
                f"fat={item.metadata.get('fat', 0)}g; cost={item.estimated_cost} VND; "
                f"tags={', '.join(item.tags)}"
            )
            for item in candidates
        )
        nutrition_constraints = self._nutrition_constraints(request)
        profile_context = self._profile_context(user_profile)
        warnings_context = "\n".join(f"- {warning}" for warning in rule_warnings or [])

        return (
            "You are FoodyLLM, a FAIR-aligned specialized language model for food and nutrition analysis.\n"
            f"Model source: {settings.foody_model_source}.\n"
            f"Original FoodyLLM task family: {settings.foody_supported_tasks}.\n"
            "This service applies FoodyLLM to an app recommendation task: use the retrieved recipe context, "
            "nutrition constraints, diet rules, allergy warnings, and user profile to score recipe suitability.\n"
            "Return strict JSON with this shape: "
            "{\"recommendations\":[{\"recipe_id\":\"...\",\"suitability_score\":0-100,"
            "\"reason\":\"...\",\"warnings\":[\"...\"]}]}.\n"
            f"User profile:\n{profile_context}\n"
            f"User query: {request.query}\n"
            f"Diet: {request.diet or 'not specified'}\n"
            f"Goal: {request.goal or 'balanced recommendation'}\n"
            f"Nutrition constraints: {nutrition_constraints}\n"
            f"Retrieved recipes:\n{context or '- No matching recipe found'}\n"
            f"Rule engine warnings:\n{warnings_context or '- none'}\n"
            "For each retrieved recipe, assess nutrition fit, diet compatibility, allergy safety, and practical cost. "
            "Score each recipe in Vietnamese, explain why it should be selected, and include warnings only when relevant."
        )

    def _nutrition_constraints(self, request: RecommendationRequest) -> dict[str, int | None]:
        return {
            "max_calories": request.max_calories,
            "target_calories": request.target_calories,
            "min_protein": request.min_protein,
            "max_carbs": request.max_carbs,
            "max_fat": request.max_fat,
            "budget": request.budget,
        }

    def _profile_context(self, user_profile: dict[str, Any] | None) -> str:
        if not user_profile:
            return "- No user profile available; use request constraints only."

        lines: list[str] = []
        user = self._dict_value(user_profile, "user")
        health_profile = self._dict_value(user_profile, "healthProfile", "health_profile")
        nutrition_goal = self._dict_value(user_profile, "nutritionGoal", "nutrition_goal")
        diet_preferences = self._list_value(user_profile, "dietPreferences", "diet_preferences")
        allergies = self._list_value(user_profile, "allergies")
        food_logs = self._list_value(user_profile, "foodLogs", "food_logs")

        if user:
            lines.append(f"- user: {user}")
        if health_profile:
            lines.append(f"- healthProfile: {health_profile}")
        if nutrition_goal:
            lines.append(f"- dailyNutritionGoal: {nutrition_goal}")
        if diet_preferences:
            lines.append(f"- dietPreferences: {diet_preferences}")
        if allergies:
            lines.append(f"- allergies: {allergies}")
        if food_logs:
            lines.append(f"- recentFoodLogs: {food_logs[:5]}")

        return "\n".join(lines) if lines else f"- {user_profile}"

    def _dict_value(self, payload: dict[str, Any], *keys: str) -> dict[str, Any]:
        for key in keys:
            value = payload.get(key)
            if isinstance(value, dict):
                return value
        return {}

    def _list_value(self, payload: dict[str, Any], *keys: str) -> list[Any]:
        for key in keys:
            value = payload.get(key)
            if isinstance(value, list):
                return value
        return []
