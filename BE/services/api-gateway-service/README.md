# API Gateway Service

Single entry point for frontend requests.

## Suggested Responsibilities

- Route frontend API calls to backend services.
- Centralize CORS configuration.
- Add JWT validation/filtering before protected routes.
- Add request logging, rate limiting, or tracing later if needed.

## Default Routes

- `/api/users/**` -> `user-service`
- `/api/recipes/**` -> `recipe-service`
- `/api/recommendations/**` -> `ai-recommendation-service`

## Local Ports

- Gateway: `8080`
- User service: `8001`
- Recipe service: `8002`
- AI recommendation service: `8003`

## Environment Variables

- `APP_PORT`
- `USER_SERVICE_URL`
- `RECIPE_SERVICE_URL`
- `AI_RECOMMENDATION_SERVICE_URL`
- `JWT_SECRET`

## Package Layout

- `config`: gateway route, CORS, and security configuration.
- `filter`: gateway filters such as JWT validation or request logging.
- `resources/application.yml`: default local route configuration.
