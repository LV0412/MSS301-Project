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

## Run Locally

```bash
mvn spring-boot:run
```

Default port: `8001`.
