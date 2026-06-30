from rag.vector_store import RecipeDocument


class ModelLoader:
    """Loads local placeholder models and recipe documents for development."""

    def load_recipe_corpus(self) -> list[RecipeDocument]:
        return [
            RecipeDocument(
                recipe_id="r001",
                name="Chicken Brown Rice Bowl",
                tags=["high-protein", "balanced", "lunch"],
                calories=520,
                protein=42,
                estimated_cost=55000,
                text="Grilled chicken, brown rice, broccoli, carrots, and light soy dressing.",
            ),
            RecipeDocument(
                recipe_id="r002",
                name="Tofu Vegetable Stir Fry",
                tags=["vegetarian", "low-fat", "dinner"],
                calories=430,
                protein=28,
                estimated_cost=42000,
                text="Tofu, mushroom, bok choy, bell pepper, and garlic sauce.",
            ),
            RecipeDocument(
                recipe_id="r003",
                name="Salmon Avocado Salad",
                tags=["omega-3", "low-carb", "dinner"],
                calories=480,
                protein=35,
                estimated_cost=78000,
                text="Salmon, avocado, mixed greens, cucumber, and lemon vinaigrette.",
            ),
            RecipeDocument(
                recipe_id="r004",
                name="Oat Banana Breakfast",
                tags=["breakfast", "high-fiber", "budget"],
                calories=390,
                protein=16,
                estimated_cost=28000,
                text="Rolled oats, banana, chia seeds, milk, and cinnamon.",
            ),
        ]
