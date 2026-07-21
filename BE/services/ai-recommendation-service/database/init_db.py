from database.database import Base, get_engine
from models.AiSuggestion import AiSuggestion  # noqa: F401
from models.SuggestedRecipe import SuggestedRecipe  # noqa: F401


def init_database() -> None:
    Base.metadata.create_all(bind=get_engine())
