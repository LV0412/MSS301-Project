import math
import re
import unicodedata
from collections import Counter
from hashlib import sha256


TOKEN_PATTERN = re.compile(r"[a-zA-Z0-9]+")


class SimpleEmbedding:
    def embed(self, text: str) -> dict[str, float]:
        tokens = TOKEN_PATTERN.findall(normalize_text(text))
        counts = Counter(tokens)
        magnitude = math.sqrt(sum(value * value for value in counts.values())) or 1.0
        return {token: value / magnitude for token, value in counts.items()}


def cosine_similarity(left: dict[str, float], right: dict[str, float]) -> float:
    return sum(value * right.get(token, 0.0) for token, value in left.items())


def normalize_text(text: str) -> str:
    normalized = unicodedata.normalize("NFD", text.lower())
    without_marks = "".join(
        character
        for character in normalized
        if unicodedata.category(character) != "Mn"
    )
    return without_marks.replace("đ", "d")


def build_recipe_text(recipe: dict) -> str:
    ingredients = recipe.get("ingredients", [])
    diet = recipe.get("diet", [])
    allergens = recipe.get("allergens", [])
    text_parts = [
        str(recipe.get("name", "")),
        str(recipe.get("description", "")),
        str(recipe.get("meal_type", "")),
        " ".join(str(item) for item in ingredients if item),
        " ".join(str(item) for item in diet if item),
        " ".join(str(item) for item in allergens if item),
    ]
    return " ".join(text_parts)


def embed_recipe(recipe: dict, dimensions: int = 384) -> list[float]:
    """Return a deterministic local hashing embedding for Chroma indexing."""
    vector = [0.0] * dimensions
    for token in TOKEN_PATTERN.findall(normalize_text(build_recipe_text(recipe))):
        digest = sha256(token.encode("utf-8")).digest()
        index = int.from_bytes(digest[:4], "big") % dimensions
        vector[index] += -1.0 if digest[4] & 1 else 1.0
    magnitude = math.sqrt(sum(value * value for value in vector)) or 1.0
    return [value / magnitude for value in vector]
