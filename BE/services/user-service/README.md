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

## Tech Stack

- Spring Boot 3
- Java 21
- Spring Data JPA
- MySQL
- Maven
- Lombok

## Project Structure

```text
src/main/java/com/mss301/userservice/
  controller/   REST controllers
  service/      business logic and orchestration
  repository/   Spring Data JPA repositories
  dto/          request/response DTOs
  entity/       JPA entities and enums
  exception/    custom exceptions and global handler
  mapper/       object mapping helpers
```

## User Management API

Base path: `/api/v1/users`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users` | Create user |
| `GET` | `/api/v1/users/{userId}` | Get user by ID |
| `GET` | `/api/v1/users?page=0&size=20&sort=createdAt,desc` | Get users with pagination and sorting |
| `PUT` | `/api/v1/users/{userId}` | Update user |
| `DELETE` | `/api/v1/users/{userId}` | Delete user |

Responses never expose `password_hash`.

## Health Profile API

Base path: `/api/v1/users/{userId}/health-profile`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/{userId}/health-profile` | Create health profile |
| `GET` | `/api/v1/users/{userId}/health-profile` | View health profile |
| `PUT` | `/api/v1/users/{userId}/health-profile` | Update health profile |
| `DELETE` | `/api/v1/users/{userId}/health-profile` | Delete health profile |

Each user can own only one health profile. BMI is calculated automatically from `height` in centimeters and `weight` in kilograms:

```text
BMI = weight / ((height / 100)^2)
```

## Nutrition Goal API

Base path: `/api/v1/users/{userId}/nutrition-goal`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/{userId}/nutrition-goal` | Create nutrition goal |
| `GET` | `/api/v1/users/{userId}/nutrition-goal` | Get nutrition goal |
| `PUT` | `/api/v1/users/{userId}/nutrition-goal` | Update nutrition goal |
| `DELETE` | `/api/v1/users/{userId}/nutrition-goal` | Delete nutrition goal |

Each user can own only one nutrition goal.

Validation:

- `calories > 0`
- `protein >= 0`
- `carbs >= 0`
- `fat >= 0`

## Diet Preference API

Base path: `/api/v1/users/{userId}/diet-preferences`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/{userId}/diet-preferences` | Add diet preference |
| `GET` | `/api/v1/users/{userId}/diet-preferences` | View diet preferences |
| `PUT` | `/api/v1/users/{userId}/diet-preferences/{preferenceId}` | Update diet preference |
| `DELETE` | `/api/v1/users/{userId}/diet-preferences/{preferenceId}` | Delete diet preference |

A user can have multiple diet preferences, but cannot have duplicate `diet_type` values.

## User Allergy API

Base path: `/api/v1/users/{userId}/allergies`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/{userId}/allergies` | Add allergy |
| `GET` | `/api/v1/users/{userId}/allergies` | View allergy list |
| `PUT` | `/api/v1/users/{userId}/allergies/{allergyId}` | Update allergy |
| `DELETE` | `/api/v1/users/{userId}/allergies/{allergyId}` | Delete allergy |

A user can have multiple allergies, but cannot have duplicate `allergen_id` values. The service stores `allergen_id` only and does not validate it with Recipe Service.

Severity values:

- `LOW`
- `MEDIUM`
- `HIGH`

## Favorite API

Base path: `/api/v1/users/{userId}/favorites`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/{userId}/favorites` | Add favorite |
| `GET` | `/api/v1/users/{userId}/favorites` | View favorite list |
| `PUT` | `/api/v1/users/{userId}/favorites/{favoriteId}` | Update favorite |
| `DELETE` | `/api/v1/users/{userId}/favorites/{favoriteId}` | Delete favorite |

One user cannot save the same recipe twice. The service stores `recipe_id` only and does not validate recipe existence with Recipe Service.

## Food Log API

Base path: `/api/v1/users/{userId}/food-logs`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/{userId}/food-logs` | Create food log |
| `GET` | `/api/v1/users/{userId}/food-logs` | View food log history |
| `PUT` | `/api/v1/users/{userId}/food-logs/{logId}` | Update food log |
| `DELETE` | `/api/v1/users/{userId}/food-logs/{logId}` | Delete food log |

Food log history supports pagination and optional filters:

```text
GET /api/v1/users/{userId}/food-logs?date=2026-06-27&mealType=BREAKFAST&page=0&size=20&sort=logDate,desc
```

The service stores `recipe_id` only and does not validate recipe existence with Recipe Service. `quantity` must be greater than zero.

Meal type values:

- `BREAKFAST`
- `LUNCH`
- `DINNER`
- `SNACK`

## Internal APIs

Base path: `/api/internal`

Internal APIs are read-only and intended for other microservices such as AI Recommendation Service. They return only the fields needed for service-to-service usage and never expose `password_hash`.

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/internal/users/{userId}` | Get minimal user profile |
| `GET` | `/api/internal/health-profiles/{userId}` | Get health profile |
| `GET` | `/api/internal/health-profiles/{userId}/status` | Get health profile completion status |
| `GET` | `/api/internal/nutrition-goals/{userId}` | Get nutrition goal |
| `GET` | `/api/internal/diet-preferences/{userId}` | Get diet preferences |
| `GET` | `/api/internal/user-allergies/{userId}` | Get allergies |
| `GET` | `/api/internal/food-logs/{userId}` | Get food logs |
| `GET` | `/api/internal/ai-profile/{userId}` | Get aggregated AI profile |

Health profile status is `COMPLETE` only when `height`, `weight`, and `activityLevel` are present.

## Run Locally

```bash
mvn spring-boot:run
```

Default port: `8001`.
