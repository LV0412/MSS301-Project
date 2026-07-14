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
- `CORS_ALLOWED_ORIGINS`
- `ADMIN_DEFAULT_USER_PASSWORD` (required when admins create user accounts)

Optional integrations:

- `GOOGLE_CLIENT_ID`
- `MAIL_HOST`
- `MAIL_USERNAME`
- `MAIL_PASSWORD`

If `MAIL_HOST` is empty, OTP and password reset tokens are logged to the service console.

Security defaults:

- Refresh tokens use `tokenId.secret`; the token ID is public and the secret is stored as BCrypt hash.
- Failed password login attempts lock the account temporarily.
- In-memory rate limiting protects login, OTP, and password reset flows.
- Production startup validates JWT, DB password, and unsafe JPA `ddl-auto` settings.
- Admin-created accounts use `ADMIN_DEFAULT_USER_PASSWORD`; replace the development default in every deployed environment.

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

For local PowerShell runs, set DB password before starting if your MySQL root user requires one:

```powershell
$env:AUTH_DATABASE_PASSWORD="your_mysql_password"
mvn spring-boot:run
```

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
