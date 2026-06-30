import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    service_name: str = os.getenv("AI_SERVICE_NAME", "ai-recommendation-service")
    service_port: int = int(os.getenv("AI_SERVICE_PORT", "8004"))
    top_k: int = int(os.getenv("AI_TOP_K", "5"))
    llm_provider: str = os.getenv("AI_LLM_PROVIDER", "local")


settings = Settings()
