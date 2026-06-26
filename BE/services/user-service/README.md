# User Service

Owns user-related data and behavior.

## Domain Entities

- `USER`
- `HEALTH_PROFILE`
- `DIET_PREFERENCE`
- `NUTRITION_GOAL`
- `ALLERGY`
- `FAVORITE`
- `FOOD_LOG`

## Suggested Responsibilities

- User account/profile APIs.
- Health profile management.
- Diet preference and allergy management.
- Nutrition goals.
- Favorite recipes.
- Food logs.

## MVC Package Layout

- `controller`: REST APIs for users, health profiles, preferences, allergies, favorites, and food logs.
- `dto`: request/response objects.
- `model`: JPA entities.
- `repository`: Spring Data repositories.
- `service`: business logic.
- `config`: security, CORS, and service configuration.
