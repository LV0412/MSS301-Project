from fastapi.testclient import TestClient

import api.recommendation as recommendation_api
from app import app
from rag.vector_store import RecipeDocument


def recipe_document() -> RecipeDocument:
    return RecipeDocument(
        recipe_id="10",
        name="Cơm gà rau củ",
        tags=["NORMAL", "high_protein"],
        calories=510,
        protein=38,
        estimated_cost=0,
        text="cơm gà rau củ",
        metadata={
            "diet": ["NORMAL"],
            "allergens": [],
            "ingredient_ids": [2, 3],
            "ingredients": ["Ức gà", "Gạo lứt", "Cà chua"],
            "ingredient_details": [
                {"ingredient_id": 2, "name": "Ức gà", "quantity": 200, "unit": "g"},
                {"ingredient_id": 3, "name": "Gạo lứt", "quantity": 100, "unit": "g"},
                {"ingredient_id": 4, "name": "Cà chua", "quantity": 1, "unit": "quả"},
            ],
            "description": "Món giàu đạm.",
            "carbs": 52,
            "fat": 12,
            "fiber": 7,
            "nutrition": {"calories": 510, "protein": 38, "vitaminC": 12},
            "preparation_time": 10,
            "cook_time": 20,
            "servings": 2,
            "difficulty": "EASY",
            "image_url": "https://example.com/recipe.jpg",
            "steps": [
                {"step_order": 1, "instruction": "Sơ chế nguyên liệu."},
                {"step_order": 2, "instruction": "Nấu chín và trình bày."},
            ],
            "source": "recipe-service",
        },
    )


def test_recommend_uses_user_profile_ingredients_and_returns_full_recipe(monkeypatch):
    monkeypatch.setattr(
        recommendation_api.user_service_client,
        "get_ai_profile",
        lambda _user_id: {
            "nutritionGoal": {"calories": 1800, "protein": 90, "carbs": 210, "fat": 60},
            "dietPreferences": [{"dietType": "NORMAL"}],
            "allergies": [{"allergenId": 9, "severity": "HIGH"}],
        },
    )
    monkeypatch.setattr(
        recommendation_api.recipe_service_client,
        "resolve_ingredient_ids",
        lambda _names: [2, 3],
    )
    monkeypatch.setattr(
        recommendation_api.recipe_service_client,
        "search_recipe_documents",
        lambda **_kwargs: [recipe_document()],
    )
    monkeypatch.setattr(
        recommendation_api.llm,
        "score_recipes",
        lambda *_args, **_kwargs: [
            {
                "recipe_id": "10",
                "suitability_score": 94,
                "reason": "Phù hợp mục tiêu protein và nguyên liệu hiện có.",
                "warnings": [],
            }
        ],
    )
    monkeypatch.setattr(
        recommendation_api.llm,
        "runtime_info",
        lambda: {"provider": "foodyllm", "mode": "foodyllm", "fallback_reason": None},
    )

    response = TestClient(app).post(
        "/api/ai/recommendations",
        json={
            "user_id": "1",
            "available_ingredients": ["Ức gà", "Gạo lứt"],
            "meal_type": "lunch",
            "limit": 3,
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["user_profile_applied"] is True
    assert payload["llm_mode"] == "foodyllm"
    assert payload["recommendations"][0]["recipe_id"] == "10"
    assert payload["recommendations"][0]["ingredients"][0]["quantity"] == 200
    assert payload["recommendations"][0]["steps"][1]["step_order"] == 2
    assert payload["recommendations"][0]["nutrition"]["vitaminC"] == 12
    assert payload["recommendations"][0]["missing_ingredients"] == ["Cà chua"]


def test_strict_ingredients_removes_recipe_with_missing_ingredients(monkeypatch):
    monkeypatch.setattr(
        recommendation_api.recipe_service_client,
        "resolve_ingredient_ids",
        lambda _names: [2],
    )
    monkeypatch.setattr(
        recommendation_api.recipe_service_client,
        "search_recipe_documents",
        lambda **_kwargs: [recipe_document()],
    )
    monkeypatch.setattr(
        recommendation_api.llm,
        "score_recipes",
        lambda *_args, **_kwargs: [],
    )
    monkeypatch.setattr(
        recommendation_api.llm,
        "runtime_info",
        lambda: {"provider": "local", "mode": "fallback", "fallback_reason": "test"},
    )

    response = TestClient(app).post(
        "/api/ai/recommendations",
        json={
            "available_ingredients": ["Ức gà"],
            "strict_ingredients": True,
        },
    )

    assert response.status_code == 200
    assert response.json()["recommendations"] == []


def test_rejects_non_numeric_user_id():
    response = TestClient(app).post("/api/ai/recommendations", json={"user_id": "../../admin"})
    assert response.status_code == 422
