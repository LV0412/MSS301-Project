import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    service_name: str = os.getenv("AI_SERVICE_NAME", "ai-recommendation-service")
    service_port: int = int(os.getenv("AI_SERVICE_PORT", "8004"))
    top_k: int = int(os.getenv("AI_TOP_K", "5"))
    llm_provider: str = os.getenv("AI_LLM_PROVIDER", "local")
    recipe_service_url: str = os.getenv("RECIPE_SERVICE_URL", "http://localhost:8002")
    foody_base_model: str = os.getenv("FOODY_BASE_MODEL", "meta-llama/Meta-Llama-3-8B-Instruct")
    foody_adapter: str = os.getenv("FOODY_ADAPTER", "Matej/FoodyLLM")
    huggingface_token: str | None = os.getenv("HUGGINGFACE_TOKEN")
    llm_max_new_tokens: int = int(os.getenv("LLM_MAX_NEW_TOKENS", "512"))
    llm_temperature: float = float(os.getenv("LLM_TEMPERATURE", "0.3"))
    llm_load_in_4bit: bool = os.getenv("LLM_LOAD_IN_4BIT", "true").lower() == "true"


settings = Settings()
