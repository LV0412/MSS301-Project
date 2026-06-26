# Backend Services

Backend is split into 4 services:

1. `api-gateway-service`: frontend entry point, routing, CORS, and future auth filters.
2. `user-service`: users, health profiles, diet preferences, nutrition goals, allergies, favorites, and food logs.
3. `recipe-service`: recipes, steps, nutrition info, ingredients, and categories.
4. `ai-recommendation-service`: AI suggestions, suggested recipes, meal plans, and meal plan items.

Each service is scaffolded as a Spring Boot Maven service using a simple MVC package style.

## Folder Convention

```text
service-name/
  src/
    main/
      java/com/mss301/<service>/
        controller/   REST controllers and request routes
        dto/          request/response DTOs
        model/        JPA entities and domain models
        repository/   Spring Data repositories
        service/      business logic and orchestration
        config/       service configuration
      resources/      application config and static resources
    test/
      java/com/mss301/<service>/
  README.md           service-specific context
  .env.example        documented environment variables
  pom.xml             Maven dependencies and build config
```

Gateway services can use gateway-specific packages such as `filter/` instead of data packages like `model/` or `repository/`.

## Service Boundaries

- Frontend traffic should enter through `api-gateway-service`.
- User data belongs to `user-service`.
- Recipe catalog and recipe nutrition data belong to `recipe-service`.
- Recommendation results and meal planning belong to `ai-recommendation-service`.
- Cross-service DTOs or API contracts can be placed in `shared/contracts`.

## Default Local Routes

- Gateway: `http://localhost:8080`
- `/api/users/**` -> `user-service` on port `8001`
- `/api/recipes/**` -> `recipe-service` on port `8002`
- `/api/recommendations/**` -> `ai-recommendation-service` on port `8003`
