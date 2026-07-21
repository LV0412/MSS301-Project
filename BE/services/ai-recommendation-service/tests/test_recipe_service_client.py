from clients.recipe_service_client import RecipeServiceClient


def test_recipe_mapping_keeps_ingredients_steps_and_nutrition():
    document = RecipeServiceClient()._to_document(
        {
            "recipeId": 7,
            "title": "Salad gà",
            "description": "Nhanh và đủ chất",
            "preparationTime": 8,
            "cookTime": 12,
            "difficulty": "EASY",
            "servings": 2,
            "dietTypes": ["NORMAL"],
            "ingredients": [
                {
                    "ingredientId": 3,
                    "name": "Ức gà",
                    "quantity": 180,
                    "unit": "g",
                    "allergens": [],
                }
            ],
            "steps": [{"stepOrder": 1, "instruction": "Áp chảo gà."}],
            "nutrition": {"calories": 420, "protein": 40, "fiber": 8, "vitaminC": 15.5},
        }
    )

    assert document.recipe_id == "7"
    assert document.metadata["ingredient_ids"] == [3]
    assert document.metadata["ingredient_details"][0]["quantity"] == 180
    assert document.metadata["steps"] == [{"step_order": 1, "instruction": "Áp chảo gà."}]
    assert document.metadata["nutrition"]["vitaminC"] == 15.5


def test_resolve_ingredient_ids_maps_synonym_and_fuzzy_name(monkeypatch):
    client = RecipeServiceClient()
    catalog = {
        "content": [
            {"ingredientId": 80, "name": "Gạo lứt"},
            {"ingredientId": 93, "name": "Ức gà"},
            {"ingredientId": 98, "name": "Rau bina"},
        ]
    }
    monkeypatch.setattr(client, "_get", lambda *_args, **_kwargs: catalog)

    assert client.resolve_ingredient_ids(["gạo nâu", "rau chân vịt", "uc gaa"]) == [80, 93, 98]


def test_resolve_ingredient_ids_does_not_guess_unrelated_name(monkeypatch):
    client = RecipeServiceClient()
    catalog = {"content": [{"ingredientId": 93, "name": "Ức gà"}]}
    monkeypatch.setattr(client, "_get", lambda *_args, **_kwargs: catalog)

    assert client.resolve_ingredient_ids(["nguyên liệu hoàn toàn không tồn tại"]) == []
