# AI Recommendation Service

Owns AI-generated suggestions and meal planning data.

## Domain Entities

- `AI_SUGGESTION`
- `SUGGESTED_RECIPE`
- `MEAL_PLAN`
- `MEAL_PLAN_ITEM`

## Suggested Responsibilities

- Generate recipe recommendations.
- Store AI suggestion history.
- Build meal plans.
- Manage meal plan items.
- Integrate with user and recipe services through service APIs or contracts.

## MVC Package Layout

- `controller`: REST APIs for recommendations, AI suggestions, and meal plans.
- `dto`: request/response objects.
- `model`: JPA entities.
- `repository`: Spring Data repositories.
- `service`: recommendation and meal planning business logic.
- `client`: HTTP clients for user service, recipe service, and AI provider calls.
- `config`: service configuration.
