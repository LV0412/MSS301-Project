from typing import Any

from config import settings
from rag.embedding import build_recipe_text, embed_recipe


COLLECTION_NAME = "recipes"


def get_chroma_client():
    import chromadb

    return chromadb.PersistentClient(path=settings.chroma_path)


def get_recipe_collection():
    client = get_chroma_client()
    return client.get_or_create_collection(name=COLLECTION_NAME)


def reset_recipe_collection():
    client = get_chroma_client()
    try:
        client.delete_collection(name=COLLECTION_NAME)
    except Exception:
        pass
    return client.get_or_create_collection(name=COLLECTION_NAME)


def add_recipes_to_chroma(recipes: list[dict[str, Any]]) -> int:
    collection = get_recipe_collection()
    if not recipes:
        return 0

    collection.upsert(
        ids=[_recipe_id(recipe) for recipe in recipes],
        documents=[build_recipe_text(recipe) for recipe in recipes],
        embeddings=[embed_recipe(recipe) for recipe in recipes],
        metadatas=[_build_metadata(recipe) for recipe in recipes],
    )
    return len(recipes)


def add_recipe(recipe: dict[str, Any]) -> None:
    collection = get_recipe_collection()
    collection.add(
        ids=[_recipe_id(recipe)],
        documents=[build_recipe_text(recipe)],
        embeddings=[embed_recipe(recipe)],
        metadatas=[_build_metadata(recipe)],
    )


def update_recipe(recipe: dict[str, Any]) -> None:
    collection = get_recipe_collection()
    collection.update(
        ids=[_recipe_id(recipe)],
        documents=[build_recipe_text(recipe)],
        embeddings=[embed_recipe(recipe)],
        metadatas=[_build_metadata(recipe)],
    )


def upsert_recipe(recipe: dict[str, Any]) -> None:
    collection = get_recipe_collection()
    collection.upsert(
        ids=[_recipe_id(recipe)],
        documents=[build_recipe_text(recipe)],
        embeddings=[embed_recipe(recipe)],
        metadatas=[_build_metadata(recipe)],
    )


def delete_recipe(recipe_id: int | str) -> None:
    collection = get_recipe_collection()
    collection.delete(ids=[str(recipe_id)])


def search_recipes(query_embedding: list[float], top_k: int) -> dict[str, Any]:
    collection = get_recipe_collection()
    if collection.count() == 0:
        raise RuntimeError("Chroma recipe collection is empty. Run python -m rag.index_recipes first.")

    return collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k,
        include=["documents", "metadatas", "distances"],
    )


def _build_metadata(recipe: dict[str, Any]) -> dict[str, str | int | float]:
    ingredients = _as_string_list(recipe.get("ingredients", []))
    diet = _as_string_list(recipe.get("diet", []))
    allergens = _as_string_list(recipe.get("allergens", []))

    return {
        "recipe_id": int(_recipe_id(recipe)),
        "name": str(recipe.get("name", "")),
        "description": str(recipe.get("description", "")),
        "ingredients": ",".join(ingredients),
        "meal_type": str(recipe.get("meal_type", "")),
        "calories": int(recipe.get("calories", 0)),
        "protein": int(recipe.get("protein", 0)),
        "carbs": int(recipe.get("carbs", 0)),
        "fat": int(recipe.get("fat", 0)),
        "cost": int(recipe.get("cost", 0)),
        "cooking_time": int(recipe.get("cooking_time", 0)),
        "diet": ",".join(diet),
        "allergens": ",".join(allergens),
    }


def _recipe_id(recipe: dict[str, Any]) -> str:
    recipe_id = recipe.get("id") or recipe.get("recipe_id") or recipe.get("recipeId")
    if recipe_id is None:
        raise ValueError("Recipe is missing id")
    return str(recipe_id)


def _as_string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    return [str(item) for item in value]
