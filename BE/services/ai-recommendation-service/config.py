import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    service_name: str = os.getenv("AI_SERVICE_NAME", "ai-recommendation-service")
    service_port: int = int(os.getenv("AI_SERVICE_PORT", "8004"))
    top_k: int = int(os.getenv("AI_TOP_K", "5"))
    llm_provider: str = os.getenv("AI_LLM_PROVIDER", "foodyllm")
    user_service_url: str = os.getenv("USER_SERVICE_URL", "http://localhost:8001")
    recipe_service_url: str = os.getenv("RECIPE_SERVICE_URL", "http://localhost:8002")
    foody_base_model: str = os.getenv("FOODY_BASE_MODEL", "meta-llama/Meta-Llama-3-8B-Instruct")
    foody_adapter: str = os.getenv("FOODY_ADAPTER", "Matej/FoodyLLM")
    foody_adapter_path: str | None = os.getenv("FOODY_ADAPTER_PATH")
    huggingface_token: str | None = os.getenv("HUGGINGFACE_TOKEN")
    llm_max_new_tokens: int = int(os.getenv("LLM_MAX_NEW_TOKENS", "512"))
    llm_temperature: float = float(os.getenv("LLM_TEMPERATURE", "0.3"))
    llm_load_in_4bit: bool = os.getenv("LLM_LOAD_IN_4BIT", "true").lower() == "true"
    foody_model_source: str = os.getenv(
        "FOODY_MODEL_SOURCE",
        "FoodyLLM: FAIR-aligned specialized LLM for food and nutrition analysis",
    )
    foody_supported_tasks: str = os.getenv(
        "FOODY_SUPPORTED_TASKS",
        "nutrition_profile,traffic_light_label,food_ner,food_ontology_linking",
    )


settings = Settings()
