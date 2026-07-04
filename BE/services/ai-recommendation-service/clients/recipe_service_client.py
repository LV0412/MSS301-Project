import logging
import re
from typing import Any

import httpx

from config import settings
from rag.vector_store import RecipeDocument


logger = logging.getLogger(__name__)


class RecipeServiceClient:
    def __init__(
        self,
        base_url: str = settings.recipe_service_url,
        timeout_seconds: float = 5.0,
        max_retries: int = 3,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries

    def get_recipe(self, recipe_id: int) -> dict[str, Any]:
        return self._get(f"/api/internal/recipes/{recipe_id}")

    def search_recipes(
        self,
        query: str | None = None,
        min_calories: int | None = None,
        max_calories: int | None = None,
        diet_type: str | None = None,
        excluded_allergen_ids: list[int] | None = None,
        size: int = 20,
    ) -> list[dict[str, Any]]:
        params: dict[str, Any] = {
            "size": size,
            "sort": "createdAt,desc",
        }
        if query:
            params["query"] = query
        if min_calories is not None:
            params["minCalories"] = min_calories
        if max_calories is not None:
            params["maxCalories"] = max_calories
        if diet_type:
            params["dietType"] = diet_type
        if excluded_allergen_ids:
            params["excludedAllergenIds"] = ",".join(str(item) for item in excluded_allergen_ids)

        payload = self._get("/api/internal/recipes", params=params)
        content = payload.get("content") if isinstance(payload, dict) else None
        return content if isinstance(content, list) else []

    def search_recipe_documents(
        self,
        query: str | None = None,
        min_calories: int | None = None,
        max_calories: int | None = None,
        diet_type: str | None = None,
        excluded_allergen_ids: list[int] | None = None,
        size: int = 20,
    ) -> list[RecipeDocument]:
        recipes = self.search_recipes(
            query=query,
            min_calories=min_calories,
            max_calories=max_calories,
            diet_type=diet_type,
            excluded_allergen_ids=excluded_allergen_ids,
            size=size,
        )
        return [self._to_document(recipe) for recipe in recipes]

    def _get(self, path: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        url = f"{self.base_url}{path}"
        last_error: Exception | None = None

        for attempt in range(1, self.max_retries + 1):
            try:
                with httpx.Client(timeout=self.timeout_seconds) as client:
                    response = client.get(url, params=params)
                    response.raise_for_status()
                    return self._unwrap_response(response.json())
            except (httpx.HTTPError, ValueError) as exc:
                last_error = exc
                logger.warning(
                    "Failed to call Recipe Service %s, attempt %s/%s: %s",
                    path,
                    attempt,
                    self.max_retries,
                    exc,
                )

        raise RuntimeError(f"Could not call Recipe Service {path}") from last_error

    def _unwrap_response(self, payload: dict[str, Any]) -> dict[str, Any]:
        if isinstance(payload.get("data"), dict):
            return payload["data"]
        return payload

    def _to_document(self, recipe: dict[str, Any]) -> RecipeDocument:
        nutrition = recipe.get("nutrition") if isinstance(recipe.get("nutrition"), dict) else {}
        ingredients = recipe.get("ingredients") if isinstance(recipe.get("ingredients"), list) else []
        diet_types = self._as_string_list(recipe.get("dietTypes"))
        allergen_names, allergen_ids = self._allergens(ingredients)
        ingredient_names = [
            str(ingredient.get("name"))
            for ingredient in ingredients
            if isinstance(ingredient, dict) and ingredient.get("name")
        ]
        title = str(recipe.get("title") or recipe.get("name") or "")
        description = str(recipe.get("description") or "")
        total_time = self._to_int(recipe.get("preparationTime"), 0) + self._to_int(recipe.get("cookTime"), 0)
        tags = [*diet_types, *allergen_names]

        return RecipeDocument(
            recipe_id=str(recipe.get("recipeId") or recipe.get("id")),
            name=title,
            tags=tags,
            calories=self._to_int(nutrition.get("calories"), 0),
            protein=self._to_int(nutrition.get("protein"), 0),
            estimated_cost=0,
            text=" ".join([title, description, " ".join(ingredient_names), " ".join(diet_types)]),
            metadata={
                "meal_type": "",
                "diet": diet_types,
                "allergens": [*allergen_names, *[f"allergen:{item}" for item in allergen_ids]],
                "allergen_ids": allergen_ids,
                "ingredients": ingredient_names,
                "description": description,
                "carbs": self._to_int(nutrition.get("carbs"), 0),
                "fat": self._to_int(nutrition.get("fat"), 0),
                "cooking_time": total_time,
                "source": "recipe-service",
            },
        )

    def _allergens(self, ingredients: list[Any]) -> tuple[list[str], list[int]]:
        names: set[str] = set()
        ids: set[int] = set()
        for ingredient in ingredients:
            if not isinstance(ingredient, dict):
                continue
            allergens = ingredient.get("allergens") if isinstance(ingredient.get("allergens"), list) else []
            for allergen in allergens:
                if not isinstance(allergen, dict):
                    continue
                if allergen.get("name"):
                    names.add(str(allergen["name"]))
                allergen_id = self._to_int(allergen.get("allergenId"), 0)
                if allergen_id:
                    ids.add(allergen_id)
        return sorted(names), sorted(ids)

    def _as_string_list(self, value: Any) -> list[str]:
        if not isinstance(value, list):
            return []
        return [str(item) for item in value]

    def _to_int(self, value: Any, default: int) -> int:
        try:
            return round(float(value))
        except (TypeError, ValueError):
            return default


def normalize_diet_type(value: str | None) -> str | None:
    if not value:
        return None
    normalized = re.sub(r"[^a-zA-Z0-9]+", "_", value).strip("_").upper()
    aliases = {
        "VEGETARIAN": "VEGETARIAN",
        "VEGAN": "VEGAN",
        "NORMAL": "NORMAL",
        "KETO": "KETO",
        "LOW_CARB": "LOW_CARB",
        "LOWCARB": "LOW_CARB",
        "OVO_VEGETARIAN": "OVO_VEGETARIAN",
        "LACTO_VEGETARIAN": "LACTO_VEGETARIAN",
    }
    return aliases.get(normalized)
