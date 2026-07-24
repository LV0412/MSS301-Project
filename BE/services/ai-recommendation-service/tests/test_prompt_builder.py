from dto.request import RecommendationRequest
from prompt.prompt_builder import PromptBuilder


def test_prompt_excludes_outdated_nutrition_targets():
    profile = {
        "nutritionGoal": {
            "status": "OUTDATED",
            "outdatedReason": "HEALTH_PROFILE_CHANGED",
            "calories": 9876,
            "protein": 4321,
        }
    }

    prompt = PromptBuilder().build(RecommendationRequest(), [], profile)

    assert "dailyNutritionGoal: OUTDATED" in prompt
    assert "9876" not in prompt
    assert "4321" not in prompt
