from decimal import Decimal

from sqlalchemy import BigInteger, ForeignKey, Integer, Numeric, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.database import Base


class SuggestedRecipe(Base):
    __tablename__ = "suggested_recipe"

    suggested_recipe_id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    suggestion_id: Mapped[int] = mapped_column(
        BigInteger,
        ForeignKey("ai_suggestion.suggestion_id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    recipe_id: Mapped[int] = mapped_column(BigInteger, nullable=False, index=True)
    score: Mapped[Decimal] = mapped_column(Numeric(10, 2), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text)
    rank: Mapped[int] = mapped_column(Integer, nullable=False)

    suggestion: Mapped["AiSuggestion"] = relationship(
        "AiSuggestion",
        back_populates="suggested_recipes",
    )
