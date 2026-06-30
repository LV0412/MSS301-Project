from fastapi import FastAPI

from api.recommendation import router as recommendation_router
from config import settings


app = FastAPI(
    title=settings.service_name,
    version="0.1.0",
    description="AI recommendation service for hybrid search, RAG, FoodyLLM, and meal optimization.",
)


@app.get("/health")
def health_check() -> dict[str, str]:
    return {"status": "UP", "service": settings.service_name}


app.include_router(recommendation_router, prefix="/api/ai", tags=["recommendations"])
