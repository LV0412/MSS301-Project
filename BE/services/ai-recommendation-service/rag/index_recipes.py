from models.model_loader import load_recipes
from rag.chroma_store import add_recipes_to_chroma, reset_recipe_collection


def main() -> None:
    recipes = load_recipes()
    reset_recipe_collection()
    indexed_count = add_recipes_to_chroma(recipes)
    print(f"Indexed {indexed_count} recipes into ChromaDB.")


if __name__ == "__main__":
    main()
