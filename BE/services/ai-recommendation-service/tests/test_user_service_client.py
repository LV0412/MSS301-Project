from clients.user_service_client import UserServiceClient


def test_get_ai_profile_uses_internal_aggregate_endpoint(monkeypatch):
    client = UserServiceClient(base_url="http://user-service:8001")
    called_paths = []

    def fake_get(path):
        called_paths.append(path)
        return {
            "user": {"userId": 1},
            "nutritionGoal": {"calories": 1800},
            "dietPreferences": [{"dietType": "NORMAL"}],
            "allergies": [{"allergenId": 2}],
        }

    monkeypatch.setattr(client, "_get", fake_get)

    profile = client.get_ai_profile("1")

    assert called_paths == ["/api/internal/ai-profile/1"]
    assert profile["nutritionGoal"]["calories"] == 1800


def test_user_service_client_exposes_internal_profile_parts(monkeypatch):
    client = UserServiceClient()
    payloads = {
        "/api/internal/users/1": {"userId": 1},
        "/api/internal/health-profiles/1": {"bmi": 22.5},
        "/api/internal/health-profiles/1/status": {"status": "COMPLETE"},
        "/api/internal/nutrition-goals/1": {"protein": 90},
        "/api/internal/diet-preferences/1": [{"dietType": "VEGAN"}],
        "/api/internal/user-allergies/1": [{"allergenId": 7}],
        "/api/internal/food-logs/1": [{"recipeId": 10}],
    }

    monkeypatch.setattr(client, "_get", lambda path: payloads[path])

    assert client.get_user("1") == {"userId": 1}
    assert client.get_health_profile("1") == {"bmi": 22.5}
    assert client.get_health_profile_status("1") == {"status": "COMPLETE"}
    assert client.get_nutrition_goal("1") == {"protein": 90}
    assert client.get_diet_preferences("1") == [{"dietType": "VEGAN"}]
    assert client.get_user_allergies("1") == [{"allergenId": 7}]
    assert client.get_food_logs("1") == [{"recipeId": 10}]


def test_get_ai_profile_returns_none_when_user_service_unavailable(monkeypatch):
    client = UserServiceClient()

    def unavailable(_path):
        raise RuntimeError("Could not call User Service")

    monkeypatch.setattr(client, "_get", unavailable)

    assert client.get_ai_profile("1") is None
