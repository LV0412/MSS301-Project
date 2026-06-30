import math
import re
from collections import Counter


TOKEN_PATTERN = re.compile(r"[a-zA-Z0-9]+")


class SimpleEmbedding:
    def embed(self, text: str) -> dict[str, float]:
        tokens = TOKEN_PATTERN.findall(text.lower())
        counts = Counter(tokens)
        magnitude = math.sqrt(sum(value * value for value in counts.values())) or 1.0
        return {token: value / magnitude for token, value in counts.items()}


def cosine_similarity(left: dict[str, float], right: dict[str, float]) -> float:
    return sum(value * right.get(token, 0.0) for token, value in left.items())
