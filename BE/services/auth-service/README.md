# Auth Service

Owns authentication, account identity, token issuance, and account security flows.

## Documents

- [API.md](./API.md): endpoint list, auth flows, request and response examples.
- [ERROR_CODES.md](./ERROR_CODES.md): standardized error response format and error code catalog.

## Tech Stack

- Spring Boot 3.3.5
- Java 21
- Spring Security
- Spring Data JPA
- MySQL
- Maven
- Lombok
- Springdoc OpenAPI

## Base URL

```text
http://localhost:8000
```

API base path:

```text
/api/v1/auth
```

## Swagger

```text
http://localhost:8000/swagger-ui/index.html
```

OpenAPI JSON:

```text
http://localhost:8000/v3/api-docs
```

Swagger UI includes Bearer JWT authorization. Use the `Authorize` button with:

```text
Bearer <access_token>
```

## Environment

See [.env.example](./.env.example).

Required for local development:

- `AUTH_DATABASE_URL`
- `AUTH_DATABASE_USERNAME`
- `AUTH_DATABASE_PASSWORD`
- `JWT_SECRET`

Optional integrations:

- `GOOGLE_CLIENT_ID`
- `MAIL_HOST`
- `MAIL_USERNAME`
- `MAIL_PASSWORD`

If `MAIL_HOST` is empty, OTP and password reset tokens are logged to the service console.

## Run Locally

Create the database:

```sql
CREATE DATABASE auth_service;
```

Run:

```bash
mvn spring-boot:run
```

Default port: `8000`.

## Docker

From the repo root:

```bash
docker compose up --build auth-service auth-mysql
```

Stop:

```bash
docker compose down
```

Build only:

```bash
docker build -t mss301-auth-service ./BE/services/auth-service
```

## Main Flows

```text
register -> verify-email -> login -> me -> refresh -> logout
```

```text
forgot-password -> reset-password -> login
```

```text
google login -> verify Google ID token -> create/find account -> issue tokens
```
