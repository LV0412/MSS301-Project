# Backend Services

Backend is split into 3 services based on the current ERD:

1. `user-service`: users, health profiles, diet preferences, nutrition goals, allergies, favorites, and food logs.
2. `recipe-service`: recipes, steps, nutrition info, ingredients, and categories.
3. `ai-recommendation-service`: AI suggestions, suggested recipes, meal plans, and meal plan items.

Each service is scaffolded with the same folder format so it can be pushed to Git now and filled with a concrete framework later.

## Folder Convention

```text
service-name/
  src/
    api/              HTTP controllers, routes, request/response DTOs
    application/      use cases and service-level orchestration
    domain/           entities, value objects, domain rules
    infrastructure/   database, repositories, integrations, clients
    config/           service configuration
  tests/              unit and integration tests
  README.md           service-specific context
  .env.example        documented environment variables
```

## Service Boundaries

- User data belongs to `user-service`.
- Recipe catalog and recipe nutrition data belong to `recipe-service`.
- Recommendation results and meal planning belong to `ai-recommendation-service`.
- Cross-service DTOs or API contracts can be placed in `shared/contracts`.
