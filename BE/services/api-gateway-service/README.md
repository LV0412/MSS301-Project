# API Gateway Service

Single entry point for frontend requests.

## Suggested Responsibilities

- Route frontend API calls to backend services.
- Centralize CORS configuration.
- Add JWT validation/filtering before protected routes.
- Add request logging, rate limiting, or tracing later if needed.

## Default Routes

- `/api/v1/auth/**` -> `auth-service`
- `/api/v1/users/**` -> `user-service`
- `/api/internal/users/**`, `/api/internal/health-profiles/**`, `/api/internal/nutrition-goals/**`, `/api/internal/diet-preferences/**`, `/api/internal/user-allergies/**`, `/api/internal/food-logs/**`, `/api/internal/ai-profile/**` -> `user-service`
- `/api/recipes/**`, `/api/v1/recipes/**`, `/api/ingredients/**`, `/api/v1/ingredients/**`, `/api/categories/**`, `/api/v1/categories/**`, `/api/allergens/**`, `/api/v1/allergens/**`, `/api/internal/recipes/**` -> `recipe-service`
- `/api/ai/**` -> `ai-recommendation-service`

## Swagger UI Aggregation

Gateway exposes a combined Swagger UI:

```text
http://localhost:8080/swagger-ui/index.html
```

The dropdown currently includes:

- Auth Service: `/v3/api-docs/auth`
- User Service: `/v3/api-docs/users`
- Recipe Service: `/v3/api-docs/recipes`

AI Recommendation is intentionally not included yet.

## Local Ports

- Gateway: `8080`
- User service: `8001`
- Recipe service: `8002`
- AI recommendation service: `8003`

## Environment Variables

- `APP_PORT`
- `AUTH_SERVICE_URL`
- `USER_SERVICE_URL`
- `RECIPE_SERVICE_URL`
- `AI_RECOMMENDATION_SERVICE_URL`
- `JWT_SECRET`

When running with Docker Compose, set service URLs to Compose DNS names:

- `AUTH_SERVICE_URL=http://auth-service:8000`
- `USER_SERVICE_URL=http://user-service:8001`
- `RECIPE_SERVICE_URL=http://recipe-service:8002`
- `AI_RECOMMENDATION_SERVICE_URL=http://ai-recommendation-service:8003`

## Package Layout

- `config`: gateway route, CORS, and security configuration.
- `filter`: gateway filters such as JWT validation or request logging.
- `resources/application.yml`: default local route configuration.
