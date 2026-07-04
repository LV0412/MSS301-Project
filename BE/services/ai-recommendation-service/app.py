from fastapi import FastAPI

from api.recommendation import router as recommendation_router
from config import settings


app = FastAPI(
    title="AI Recommendation Service API",
    version="0.1.0",
    description=(
        "AI recommendation service for Recipe Service backed retrieval, hybrid search, "
        "RAG prompt building, FoodyLLM generation, and meal optimization."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
    openapi_tags=[
        {
            "name": "health",
            "description": "Service health and readiness checks.",
        },
        {
            "name": "recommendations",
            "description": (
                "Generate food recommendations from user intent, diet, allergies, "
                "calorie limits, and Recipe Service candidates."
            ),
        },
    ],
)


@app.get(
    "/health",
    tags=["health"],
    summary="Health check",
    description="Return the current status of the AI recommendation service.",
)
def health_check() -> dict[str, str]:
    return {"status": "UP", "service": settings.service_name}


app.include_router(recommendation_router, prefix="/api/ai", tags=["recommendations"])
