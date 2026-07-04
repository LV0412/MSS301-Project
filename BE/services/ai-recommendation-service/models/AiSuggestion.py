from datetime import datetime

from sqlalchemy import BigInteger, DateTime, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.database import Base


class AiSuggestion(Base):
    __tablename__ = "ai_suggestion"

    suggestion_id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(BigInteger, nullable=False, index=True)
    model_name: Mapped[str] = mapped_column(String(100), nullable=False)
    generated_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)

    suggested_recipes: Mapped[list["SuggestedRecipe"]] = relationship(
        "SuggestedRecipe",
        back_populates="suggestion",
        cascade="all, delete-orphan",
    )
