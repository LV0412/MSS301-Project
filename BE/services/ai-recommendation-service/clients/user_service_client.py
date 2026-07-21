import logging
from typing import Any

import httpx

from config import settings


logger = logging.getLogger(__name__)


class UserServiceClient:
    def __init__(
        self,
        base_url: str = settings.user_service_url,
        timeout_seconds: float = 3.0,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout_seconds = timeout_seconds

    def get_ai_profile(self, user_id: str) -> dict[str, Any] | None:
        url = f"{self.base_url}/api/internal/ai-profile/{user_id}"
        try:
            with httpx.Client(timeout=self.timeout_seconds) as client:
                response = client.get(url)
                response.raise_for_status()
                return self._unwrap_response(response.json())
        except (httpx.HTTPError, ValueError) as exc:
            logger.warning("Failed to fetch AI profile for user %s: %s", user_id, exc)
            return None

    def _unwrap_response(self, payload: dict[str, Any]) -> dict[str, Any]:
        if isinstance(payload.get("data"), dict):
            return payload["data"]
        return payload
