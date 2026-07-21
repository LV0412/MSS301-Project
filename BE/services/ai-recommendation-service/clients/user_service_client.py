import logging
import time
from typing import Any

import httpx

from config import settings


logger = logging.getLogger(__name__)


class UserServiceClient:
    def __init__(
        self,
        base_url: str = settings.user_service_url,
        timeout_seconds: float = 3.0,
        max_retries: int = 2,
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout_seconds = timeout_seconds
        self.max_retries = max_retries
        self._unavailable_until = 0.0

    def get_ai_profile(self, user_id: str) -> dict[str, Any] | None:
        try:
            payload = self._get(f"/api/internal/ai-profile/{user_id}")
            return payload if isinstance(payload, dict) else None
        except RuntimeError as exc:
            logger.warning("Failed to fetch AI profile for user %s: %s", user_id, exc)
            return None

    def get_user(self, user_id: str) -> dict[str, Any]:
        return self._get(f"/api/internal/users/{user_id}")

    def get_health_profile(self, user_id: str) -> dict[str, Any]:
        return self._get(f"/api/internal/health-profiles/{user_id}")

    def get_health_profile_status(self, user_id: str) -> dict[str, Any]:
        return self._get(f"/api/internal/health-profiles/{user_id}/status")

    def get_nutrition_goal(self, user_id: str) -> dict[str, Any]:
        return self._get(f"/api/internal/nutrition-goals/{user_id}")

    def get_diet_preferences(self, user_id: str) -> list[dict[str, Any]]:
        payload = self._get(f"/api/internal/diet-preferences/{user_id}")
        return payload if isinstance(payload, list) else []

    def get_user_allergies(self, user_id: str) -> list[dict[str, Any]]:
        payload = self._get(f"/api/internal/user-allergies/{user_id}")
        return payload if isinstance(payload, list) else []

    def get_food_logs(self, user_id: str) -> list[dict[str, Any]]:
        payload = self._get(f"/api/internal/food-logs/{user_id}")
        return payload if isinstance(payload, list) else []

    def _get(self, path: str) -> Any:
        if time.monotonic() < self._unavailable_until:
            raise RuntimeError("User Service circuit breaker is open")

        url = f"{self.base_url}{path}"
        last_error: Exception | None = None

        for attempt in range(1, self.max_retries + 1):
            try:
                with httpx.Client(timeout=self.timeout_seconds) as client:
                    response = client.get(url)
                    response.raise_for_status()
                    return self._unwrap_response(response.json())
            except httpx.HTTPStatusError as exc:
                if exc.response.status_code < 500:
                    raise RuntimeError(f"User Service rejected {path} with HTTP {exc.response.status_code}") from exc
                last_error = exc
                logger.warning(
                    "Failed to call User Service %s, attempt %s/%s: %s",
                    path,
                    attempt,
                    self.max_retries,
                    exc,
                )
            except (httpx.RequestError, ValueError) as exc:
                last_error = exc
                logger.warning(
                    "Failed to call User Service %s, attempt %s/%s: %s",
                    path,
                    attempt,
                    self.max_retries,
                    exc,
                )

        self._unavailable_until = time.monotonic() + 10.0
        raise RuntimeError(f"Could not call User Service {path}") from last_error

    def _unwrap_response(self, payload: Any) -> Any:
        if isinstance(payload, dict) and isinstance(payload.get("data"), (dict, list)):
            return payload["data"]
        return payload
