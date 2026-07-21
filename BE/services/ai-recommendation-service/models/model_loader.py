import json
from pathlib import Path
from typing import Any

from rag.embedding import build_recipe_text
from rag.vector_store import RecipeDocument


RECIPES_PATH = Path(__file__).resolve().parents[1] / "data" / "recipes.json"


def load_recipes(path: Path = RECIPES_PATH) -> list[dict[str, Any]]:
    try:
        with path.open("r", encoding="utf-8") as recipes_file:
            recipes = json.load(recipes_file)
    except FileNotFoundError as exc:
        raise FileNotFoundError(f"Recipe data file not found: {path}") from exc
    except json.JSONDecodeError as exc:
        raise ValueError(f"Recipe data file contains invalid JSON: {path}") from exc

    if not isinstance(recipes, list):
        raise ValueError(f"Recipe data must be a list: {path}")

    return recipes


class ModelLoader:
    """Loads recipe data from the local JSON knowledge base."""

    def load_recipe_corpus(self) -> list[RecipeDocument]:
        return [self._to_document(recipe) for recipe in load_recipes()]

    def _to_document(self, recipe: dict[str, Any]) -> RecipeDocument:
        diet = self._as_string_list(recipe.get("diet", []))
        allergens = self._as_string_list(recipe.get("allergens", []))
        ingredients = self._as_string_list(recipe.get("ingredients", []))
        meal_type = str(recipe.get("meal_type", ""))

        return RecipeDocument(
            recipe_id=str(recipe["id"]),
            name=str(recipe["name"]),
            tags=[meal_type, *diet, *allergens],
            calories=int(recipe["calories"]),
            protein=int(recipe["protein"]),
            estimated_cost=int(recipe["cost"]),
            text=build_recipe_text(recipe),
            metadata={
                "meal_type": meal_type,
                "diet": diet,
                "allergens": allergens,
                "ingredients": ingredients,
                "ingredient_details": [
                    {"ingredient_id": None, "name": name, "quantity": None, "unit": None}
                    for name in ingredients
                ],
                "ingredient_ids": [],
                "description": str(recipe.get("description", "")),
                "carbs": int(recipe["carbs"]),
                "fat": int(recipe["fat"]),
                "cooking_time": int(recipe["cooking_time"]),
                "preparation_time": 0,
                "cook_time": int(recipe["cooking_time"]),
                "servings": None,
                "difficulty": None,
                "image_url": None,
                "fiber": int(recipe.get("fiber", 0)),
                "nutrition": {
                    "calories": float(recipe["calories"]),
                    "protein": float(recipe["protein"]),
                    "carbs": float(recipe["carbs"]),
                    "fat": float(recipe["fat"]),
                    "fiber": float(recipe.get("fiber", 0)),
                },
                "steps": [],
                "source": "local-recipes-json",
            },
        )

    def _as_string_list(self, value: Any) -> list[str]:
        if not isinstance(value, list):
            return []
        return [str(item) for item in value]
