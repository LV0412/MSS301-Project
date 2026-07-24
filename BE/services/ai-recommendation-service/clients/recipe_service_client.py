import logging
import re
import time
import unicodedata
from difflib import SequenceMatcher
from typing import Any

import httpx

from config import settings
from rag.vector_store import RecipeDocument


logger = logging.getLogger(__name__)


INGREDIENT_ALIASES = {
    "brown rice": "gao lut",
    "cai bo xoi": "rau bina",
    "gao nau": "gao lut",
    "phi le ga": "uc ga",
    "rau chan vit": "rau bina",
    "spinach": "rau bina",
    "thit ga phi le": "uc ga",
}


def normalize_ingredient_name(value: str) -> str:
    decomposed = unicodedata.normalize("NFD", value.casefold().strip())
    without_accents = "".join(char for char in decomposed if unicodedata.category(char) != "Mn")
    return re.sub(r"[^a-z0-9]+", " ", without_accents).strip()


class RecipeServiceClient:
    def __init__(
        self,
        base_url: str = settings.recipe_service_url,
        timeout_seconds: float = 3.0,
        max_retries: int = 2,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self._unavailable_until = 0.0

    def get_recipe(self, recipe_id: int) -> dict[str, Any]:
        return self._get(f"/api/internal/recipes/{recipe_id}")

    def get_recipe_document(self, recipe_id: int) -> RecipeDocument:
        return self._to_document(self.get_recipe(recipe_id))

    def get_catalog_snapshot_documents(self) -> list[RecipeDocument]:
        payload = self._get("/api/internal/recipes/snapshot")
        recipes = payload.get("recipes") if isinstance(payload, dict) else None
        if not isinstance(recipes, list):
            return []
        return [self._to_document(recipe) for recipe in recipes if isinstance(recipe, dict)]

    def search_recipes(
        self,
        query: str | None = None,
        min_calories: int | None = None,
        max_calories: int | None = None,
        diet_type: str | None = None,
        excluded_allergen_ids: list[int] | None = None,
        ingredient_ids: list[int] | None = None,
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
        if ingredient_ids:
            params["ingredientIds"] = ",".join(str(item) for item in ingredient_ids)

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
        ingredient_ids: list[int] | None = None,
        size: int = 20,
    ) -> list[RecipeDocument]:
        recipes = self.search_recipes(
            query=query,
            min_calories=min_calories,
            max_calories=max_calories,
            diet_type=diet_type,
            excluded_allergen_ids=excluded_allergen_ids,
            ingredient_ids=ingredient_ids,
            size=size,
        )
        return [self._to_document(recipe) for recipe in recipes]

    def resolve_ingredient_ids(self, names: list[str]) -> list[int]:
        resolved: set[int] = set()
        for name in names:
            normalized = normalize_ingredient_name(name)
            if not normalized:
                continue
            target = INGREDIENT_ALIASES.get(normalized, normalized)
            candidates = self._ingredient_candidates(target)
            match = self._best_ingredient_match(target, candidates)
            if match is not None:
                ingredient_id = self._to_int(match.get("ingredientId"), 0)
                if ingredient_id:
                    resolved.add(ingredient_id)
        return sorted(resolved)

    def _ingredient_candidates(self, normalized_name: str) -> list[dict[str, Any]]:
        payload = self._get("/api/ingredients", params={"query": normalized_name, "size": 20})
        content = payload.get("content") if isinstance(payload, dict) else None
        if isinstance(content, list) and content:
            return [item for item in content if isinstance(item, dict)]

        # Recipe Service may not find misspellings. Fetch its small ingredient catalog
        # and perform the fuzzy comparison here so Recipe Service stays unchanged.
        payload = self._get("/api/ingredients", params={"size": 500})
        content = payload.get("content") if isinstance(payload, dict) else None
        return [item for item in content if isinstance(item, dict)] if isinstance(content, list) else []

    def _best_ingredient_match(
        self,
        normalized_name: str,
        candidates: list[dict[str, Any]],
        threshold: float = 0.78,
    ) -> dict[str, Any] | None:
        scored = [
            (
                SequenceMatcher(
                    None,
                    normalized_name,
                    normalize_ingredient_name(str(item.get("name") or "")),
                ).ratio(),
                item,
            )
            for item in candidates
            if item.get("name")
        ]
        if not scored:
            return None
        score, item = max(scored, key=lambda pair: pair[0])
        return item if score >= threshold else None

    def _get(self, path: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        if time.monotonic() < self._unavailable_until:
            raise RuntimeError("Recipe Service circuit breaker is open")
        url = f"{self.base_url}{path}"
        last_error: Exception | None = None

        for attempt in range(1, self.max_retries + 1):
            try:
                with httpx.Client(timeout=self.timeout_seconds) as client:
                    response = client.get(url, params=params)
                    response.raise_for_status()
                    return self._unwrap_response(response.json())
            except httpx.HTTPStatusError as exc:
                if exc.response.status_code < 500:
                    raise RuntimeError(
                        f"Recipe Service rejected {path} with HTTP {exc.response.status_code}"
                    ) from exc
                last_error = exc
                logger.warning(
                    "Failed to call Recipe Service %s, attempt %s/%s: %s",
                    path,
                    attempt,
                    self.max_retries,
                    exc,
                )
            except (httpx.RequestError, ValueError) as exc:
                last_error = exc
                logger.warning(
                    "Failed to call Recipe Service %s, attempt %s/%s: %s",
                    path,
                    attempt,
                    self.max_retries,
                    exc,
                )

        self._unavailable_until = time.monotonic() + 10.0
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
        ingredient_details = [
            {
                "ingredient_id": self._to_int(ingredient.get("ingredientId"), 0) or None,
                "name": str(ingredient.get("name") or ""),
                "quantity": self._to_float(ingredient.get("quantity")),
                "unit": str(ingredient.get("unit") or "") or None,
            }
            for ingredient in ingredients
            if isinstance(ingredient, dict) and ingredient.get("name")
        ]
        ingredient_names = [item["name"] for item in ingredient_details]
        steps = recipe.get("steps") if isinstance(recipe.get("steps"), list) else []
        title = str(recipe.get("title") or recipe.get("name") or "")
        description = str(recipe.get("description") or "")
        total_time = self._to_int(recipe.get("preparationTime"), 0) + self._to_int(recipe.get("cookTime"), 0)
        meal_type = self._meal_type(recipe)
        tags = [meal_type, *diet_types, *allergen_names] if meal_type else [*diet_types, *allergen_names]

        return RecipeDocument(
            recipe_id=str(recipe.get("recipeId") or recipe.get("id")),
            name=title,
            tags=tags,
            calories=self._to_int(nutrition.get("calories"), 0),
            protein=self._to_int(nutrition.get("protein"), 0),
            estimated_cost=0,
            text=" ".join([title, description, " ".join(ingredient_names), " ".join(diet_types)]),
            metadata={
                "meal_type": meal_type,
                "diet": diet_types,
                "allergens": [*allergen_names, *[f"allergen:{item}" for item in allergen_ids]],
                "allergen_ids": allergen_ids,
                "ingredients": ingredient_names,
                "ingredient_details": ingredient_details,
                "ingredient_ids": [item["ingredient_id"] for item in ingredient_details if item["ingredient_id"]],
                "description": description,
                "carbs": self._to_int(nutrition.get("carbs"), 0),
                "fat": self._to_int(nutrition.get("fat"), 0),
                "cooking_time": total_time,
                "preparation_time": self._to_int(recipe.get("preparationTime"), 0),
                "cook_time": self._to_int(recipe.get("cookTime"), 0),
                "servings": self._to_int(recipe.get("servings"), 0) or None,
                "difficulty": str(recipe.get("difficulty") or "") or None,
                "image_url": recipe.get("imageUrl"),
                "fiber": self._to_int(nutrition.get("fiber"), 0),
                "nutrition": {
                    str(key): float(value)
                    for key, value in nutrition.items()
                    if key != "nutritionId" and isinstance(value, (int, float, str)) and self._is_number(value)
                },
                "steps": [
                    {
                        "step_order": self._to_int(step.get("stepOrder"), index + 1),
                        "instruction": str(step.get("instruction") or ""),
                    }
                    for index, step in enumerate(steps)
                    if isinstance(step, dict) and step.get("instruction")
                ],
                "source": "recipe-service",
            },
        )

    def _meal_type(self, recipe: dict[str, Any]) -> str:
        direct_value = recipe.get("mealType") or recipe.get("meal_type")
        if direct_value:
            return self._normalize_meal_type(str(direct_value))

        category = recipe.get("category") if isinstance(recipe.get("category"), dict) else {}
        category_id = self._to_int(category.get("categoryId") or recipe.get("categoryId"), 0)
        by_id = {
            1: "breakfast",
            2: "lunch",
            3: "dinner",
            4: "snack",
        }
        if category_id in by_id:
            return by_id[category_id]

        return self._normalize_meal_type(str(category.get("name") or ""))

    def _normalize_meal_type(self, value: str) -> str:
        normalized = normalize_ingredient_name(value)
        aliases = {
            "breakfast": "breakfast",
            "bua sang": "breakfast",
            "sang": "breakfast",
            "lunch": "lunch",
            "bua trua": "lunch",
            "trua": "lunch",
            "dinner": "dinner",
            "bua toi": "dinner",
            "bua chieu": "dinner",
            "toi": "dinner",
            "chieu": "dinner",
            "snack": "snack",
            "an nhe": "snack",
            "bua phu": "snack",
        }
        return aliases.get(normalized, "")

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

    def _to_float(self, value: Any) -> float | None:
        try:
            return float(value)
        except (TypeError, ValueError):
            return None

    def _is_number(self, value: Any) -> bool:
        try:
            float(value)
            return True
        except (TypeError, ValueError):
            return False


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
