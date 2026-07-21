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
- Springdoc OpenAPI / Swagger UI
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

User-owned endpoints derive the target user from the trusted `X-User-Id` header injected by the API Gateway. Client-supplied `userId` path values are not used for authorization-sensitive lookup.

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users` | Create user |
| `GET` | `/api/v1/users/me` | Get current user |
| `GET` | `/api/v1/users?page=0&size=20&sort=createdAt,desc` | Get users with pagination and sorting |
| `PUT` | `/api/v1/users/me` | Update current user |
| `DELETE` | `/api/v1/users/me` | Delete current user |

Responses never expose `password_hash`.

## Health Profile API

Base path: `/api/v1/users/me/health-profile`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/me/health-profile` | Create health profile |
| `GET` | `/api/v1/users/me/health-profile` | View health profile |
| `PUT` | `/api/v1/users/me/health-profile` | Update health profile |
| `DELETE` | `/api/v1/users/me/health-profile` | Delete health profile |

Each user can own only one health profile. BMI is calculated automatically from `height` in centimeters and `weight` in kilograms:

```text
BMI = weight / ((height / 100)^2)
```

## Nutrition Goal API

Base path: `/api/v1/users/me/nutrition-goal`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/me/nutrition-goal` | Create nutrition goal |
| `GET` | `/api/v1/users/me/nutrition-goal` | Get nutrition goal |
| `PUT` | `/api/v1/users/me/nutrition-goal` | Update nutrition goal |
| `DELETE` | `/api/v1/users/me/nutrition-goal` | Delete nutrition goal |

Each user can own only one nutrition goal.

Validation:

- `calories > 0`
- `protein >= 0`
- `carbs >= 0`
- `fat >= 0`

## Diet Preference API

Base path: `/api/v1/users/me/diet-preferences`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/me/diet-preferences` | Add diet preference |
| `GET` | `/api/v1/users/me/diet-preferences` | View diet preferences |
| `PUT` | `/api/v1/users/me/diet-preferences/{preferenceId}` | Update diet preference |
| `DELETE` | `/api/v1/users/me/diet-preferences/{preferenceId}` | Delete diet preference |

A user can have multiple diet preferences, but cannot have duplicate `diet_type` values.

## User Allergy API

Base path: `/api/v1/users/me/allergies`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/me/allergies` | Add allergy |
| `GET` | `/api/v1/users/me/allergies` | View allergy list |
| `PUT` | `/api/v1/users/me/allergies/{allergyId}` | Update allergy |
| `DELETE` | `/api/v1/users/me/allergies/{allergyId}` | Delete allergy |

A user can have multiple allergies, but cannot have duplicate `allergen_id` values. The service stores `allergen_id` only and does not validate it with Recipe Service.

Severity values:

- `LOW`
- `MEDIUM`
- `HIGH`

## Favorite API

Base path: `/api/v1/users/me/favorites`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/me/favorites` | Add favorite |
| `GET` | `/api/v1/users/me/favorites` | View favorite list |
| `PUT` | `/api/v1/users/me/favorites/{favoriteId}` | Update favorite |
| `DELETE` | `/api/v1/users/me/favorites/{favoriteId}` | Delete favorite |

One user cannot save the same recipe twice. The service stores `recipe_id` only and does not validate recipe existence with Recipe Service.

## Food Log API

Base path: `/api/v1/users/me/food-logs`

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/users/me/food-logs` | Create food log |
| `GET` | `/api/v1/users/me/food-logs` | View food log history |
| `PUT` | `/api/v1/users/me/food-logs/{logId}` | Update food log |
| `DELETE` | `/api/v1/users/me/food-logs/{logId}` | Delete food log |

Food log history supports pagination and optional filters:

```text
GET /api/v1/users/me/food-logs?date=2026-06-27&mealType=BREAKFAST&page=0&size=20&sort=logDate,desc
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

Start MySQL first, then configure environment variables:

```env
APP_PORT=8001
DATABASE_URL=jdbc:mysql://localhost:3306/user_service?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
DATABASE_USERNAME=root
DATABASE_PASSWORD=
JPA_DDL_AUTO=update
JPA_SHOW_SQL=false
```

```bash
mvn spring-boot:run
```

Default port: `8001`.

Swagger UI:

```text
http://localhost:8001/swagger-ui/index.html
```

OpenAPI JSON:

```text
http://localhost:8001/v3/api-docs
```

## Run With Docker Compose

From repository root:

```bash
docker compose up --build user-service user-mysql
```

Service URLs:

| Service | URL |
| --- | --- |
| Gateway route | `http://localhost:8080/api/v1/users` |
| User MySQL | `localhost:3308` |

The root `docker-compose.yml` starts `user-service` with `user-mysql`, uses the `user_mysql_data` volume for database persistence, and exposes `user-service` only on the internal Docker network. Requests must go through the API Gateway.

## OpenAPI

The service exposes Swagger/OpenAPI with a shared Bearer JWT security scheme for Gateway usage. JWT validation is centralized in the API Gateway.
