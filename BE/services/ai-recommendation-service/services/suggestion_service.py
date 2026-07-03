from collections.abc import Sequence

from database.session import SessionLocal
from dto.response import RecommendedItem
from repositories.ai_suggestion_repository import (
    create_ai_suggestion,
    create_suggested_recipes,
)


def save_suggestion(
    user_id: int,
    model_name: str,
    recipes: Sequence[RecommendedItem],
) -> int:
    session = SessionLocal()
    try:
        suggestion = create_ai_suggestion(session, user_id=user_id, model_name=model_name)
        create_suggested_recipes(session, suggestion.suggestion_id, recipes)
        session.commit()
        return suggestion.suggestion_id
    except Exception as exc:
        session.rollback()
        raise RuntimeError("Failed to save AI recommendation suggestion") from exc
    finally:
        session.close()
