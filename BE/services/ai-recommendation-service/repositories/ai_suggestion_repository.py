from decimal import Decimal
from typing import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from dto.response import RecommendedItem
from models.AiSuggestion import AiSuggestion
from models.SuggestedRecipe import SuggestedRecipe


def create_ai_suggestion(session: Session, user_id: int, model_name: str) -> AiSuggestion:
    suggestion = AiSuggestion(user_id=user_id, model_name=model_name)
    session.add(suggestion)
    session.flush()
    return suggestion


def create_suggested_recipes(
    session: Session,
    suggestion_id: int,
    recipes: Sequence[RecommendedItem],
) -> list[SuggestedRecipe]:
    suggested_recipes = [
        SuggestedRecipe(
            suggestion_id=suggestion_id,
            recipe_id=_to_int(recipe.recipe_id),
            score=Decimal(str(getattr(recipe, "score", 0.0))),
            reason=_build_reason(recipe),
            rank=rank,
        )
        for rank, recipe in enumerate(recipes, start=1)
    ]
    session.add_all(suggested_recipes)
    session.flush()
    return suggested_recipes


def get_suggestion(session: Session, suggestion_id: int) -> AiSuggestion | None:
    statement = (
        select(AiSuggestion)
        .options(selectinload(AiSuggestion.suggested_recipes))
        .where(AiSuggestion.suggestion_id == suggestion_id)
    )
    return session.scalar(statement)


def get_user_history(session: Session, user_id: int, limit: int = 20) -> list[AiSuggestion]:
    statement = (
        select(AiSuggestion)
        .options(selectinload(AiSuggestion.suggested_recipes))
        .where(AiSuggestion.user_id == user_id)
        .order_by(AiSuggestion.generated_at.desc())
        .limit(limit)
    )
    return list(session.scalars(statement))


def _build_reason(recipe: RecommendedItem) -> str:
    score = getattr(recipe, "score", 0.0)
    return f"Recipe ranked by AI recommendation optimizer with score {score}."


def _to_int(value: str) -> int:
    try:
        return int(value)
    except ValueError as exc:
        raise ValueError(f"recipe_id must be numeric to persist suggested_recipe: {value}") from exc
