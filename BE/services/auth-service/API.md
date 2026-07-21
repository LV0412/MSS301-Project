# Auth Service API

Base URL:

```text
http://localhost:8000
```

Base path:

```text
/api/v1/auth
```

Protected endpoints require:

```http
Authorization: Bearer <access_token>
```

## Authentication Flow

Email/password:

```text
register -> read OTP from email/console -> verify-email -> login -> me -> refresh -> logout
```

Password recovery:

```text
forgot-password -> read reset token from email/console -> reset-password -> login
```

Google:

```text
Flutter google_sign_in -> Google ID token -> POST /google -> access token + refresh token
```

## Endpoint Summary

### Public

| Method | Path | Description |
| --- | --- | --- |
| `POST` | `/api/v1/auth/register` | Register a LOCAL account |
| `POST` | `/api/v1/auth/login` | Login with email/password |
| `POST` | `/api/v1/auth/google` | Login with Google ID token |
| `POST` | `/api/v1/auth/verify-email` | Verify email using OTP |
| `POST` | `/api/v1/auth/resend-otp` | Resend email verification OTP |
| `POST` | `/api/v1/auth/forgot-password` | Request password reset |
| `POST` | `/api/v1/auth/reset-password` | Reset password using reset token |
| `POST` | `/api/v1/auth/refresh` | Rotate refresh token |

### Protected

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/v1/auth/me` | Get current account |
| `POST` | `/api/v1/auth/change-password` | Change current account password |
| `POST` | `/api/v1/auth/logout` | Revoke refresh token |
| `POST` | `/api/v1/auth/admin/accounts` | Create a user account with the configured temporary password (ADMIN only) |

## Admin Create Account

```http
POST /api/v1/auth/admin/accounts
Authorization: Bearer <admin_access_token>
```

Request:

```json
{
  "email": "new.user@example.com",
  "fullName": "New User"
}
```

The endpoint uses `ADMIN_DEFAULT_USER_PASSWORD` on the server, creates an
inactive LOCAL account, sends a verification OTP, and provisions the linked
User Service profile. The user should change the temporary password after the
first login.

## Register

```http
POST /api/v1/auth/register
```

Request:

```json
{
  "email": "test@example.com",
  "password": "Password@123",
  "fullName": "Test User"
}
```

Response `201`:

```json
{
  "message": "Account registered successfully. Please verify your email before logging in."
}
```

Notes:

- Creates account as `INACTIVE`.
- Sets `emailVerified=false`.
- Sends OTP by email if SMTP is configured.
- Logs OTP to console when `MAIL_HOST` is empty.

## Verify Email

```http
POST /api/v1/auth/verify-email
```

Request:

```json
{
  "email": "test@example.com",
  "otp": "123456"
}
```

Response `200`:

```json
{
  "message": "Email verified successfully. You can now log in."
}
```

## Resend OTP

```http
POST /api/v1/auth/resend-otp
```

Request:

```json
{
  "email": "test@example.com"
}
```

Response `200`:

```json
{
  "message": "Verification OTP has been sent."
}
```

## Login

```http
POST /api/v1/auth/login
```

Request:

```json
{
  "email": "test@example.com",
  "password": "Password@123"
}
```

Response `200`:

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "c6a9df1a-3df7-4d41-97f3-ea2fcb8c909a.X7PV0vlb0M9tDksW07fxa7P6hdcQmTX6RLTiw6ih9s4",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "account": {
    "accountId": 1,
    "email": "test@example.com",
    "fullName": "Test User",
    "role": "USER",
    "status": "ACTIVE",
    "emailVerified": true,
    "provider": "LOCAL",
    "createdAt": "2026-06-30T10:00:00",
    "updatedAt": "2026-06-30T10:03:00"
  }
}
```

## Google Login

```http
POST /api/v1/auth/google
```

Request:

```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij..."
}
```

Response `200`: same as login response.

Important behavior:

- Requires `GOOGLE_CLIENT_ID`.
- Returns `GOOGLE_AUTH_UNAVAILABLE` when Google auth is not configured.
- If the Google email does not exist, creates an active `GOOGLE` account, stores a random temporary password hash, emails the temporary password to the user, and returns access/refresh tokens immediately.
- If the Google account already exists, logs in and returns access/refresh tokens.
- If the email already exists under `LOCAL`, returns `GOOGLE_LINK_PASSWORD_REQUIRED` unless the current local password is supplied for linking.

## Get Current Account

```http
GET /api/v1/auth/me
Authorization: Bearer <access_token>
```

Response `200`:

```json
{
  "accountId": 1,
  "email": "test@example.com",
  "fullName": "Test User",
  "role": "USER",
  "status": "ACTIVE",
  "emailVerified": true,
  "provider": "LOCAL",
  "createdAt": "2026-06-30T10:00:00",
  "updatedAt": "2026-06-30T10:03:00"
}
```

## Refresh

```http
POST /api/v1/auth/refresh
```

Request:

```json
{
  "refreshToken": "c6a9df1a-3df7-4d41-97f3-ea2fcb8c909a.X7PV0vlb0M9tDksW07fxa7P6hdcQmTX6RLTiw6ih9s4"
}
```

Response `200`: same as login response.

Behavior:

- Old refresh token is revoked.
- New refresh token is issued.
- Client must store the new refresh token.
- Refresh token format is `tokenId.secret`; only the public token ID is used for lookup and the secret is verified with BCrypt.

## Logout

```http
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
```

Request:

```json
{
  "refreshToken": "c6a9df1a-3df7-4d41-97f3-ea2fcb8c909a.X7PV0vlb0M9tDksW07fxa7P6hdcQmTX6RLTiw6ih9s4"
}
```

Response `200`:

```json
{
  "message": "Logged out successfully."
}
```

## Forgot Password

```http
POST /api/v1/auth/forgot-password
```

Request:

```json
{
  "email": "test@example.com"
}
```

Response `200`:

```json
{
  "message": "If the email exists, password reset instructions have been sent."
}
```

The response is intentionally identical whether the email exists or not.

## Reset Password

```http
POST /api/v1/auth/reset-password
```

Request:

```json
{
  "resetToken": "NFPYV6eSz7lG1Q2wX8XUCk-ctn7nU0G8wAg2TjJxnQw",
  "newPassword": "NewPassword@123"
}
```

Response `200`:

```json
{
  "message": "Password has been reset successfully. Please log in with your new password."
}
```

Behavior:

- Marks reset token as consumed.
- Updates password hash.
- Revokes all active refresh tokens for the account.

## Change Password

```http
POST /api/v1/auth/change-password
Authorization: Bearer <access_token>
```

Request:

```json
{
  "currentPassword": "OldPassword@123",
  "newPassword": "NewPassword@123",
  "confirmPassword": "NewPassword@123"
}
```

Response `200`:

```json
{
  "message": "Password changed successfully. Please log in again."
}
```

Behavior:

- Requires LOCAL account.
- Validates current password.
- Validates `newPassword == confirmPassword`.
- Blocks password reuse.
- Revokes all active refresh tokens.
- Current access token remains valid until expiry.

## Error Response

All errors use the same shape:

```json
{
  "timestamp": "2026-06-30T10:30:45",
  "status": 400,
  "error": "Bad Request",
  "code": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "path": "/api/v1/auth/login",
  "validationErrors": {
    "email": "must not be blank"
  }
}
```

See [ERROR_CODES.md](./ERROR_CODES.md).

## Rate Limits

The service applies in-memory rate limits to abuse-sensitive flows:

| Flow | Default limit | Window |
| --- | ---: | --- |
| Login | `10` requests | `60` seconds |
| Resend OTP | `3` requests | `60` seconds |
| Verify email | `10` requests | `60` seconds |
| Forgot password | `3` requests | `60` seconds |
| Reset password | `10` requests | `60` seconds |

The implementation is intentionally behind a `RateLimiter` interface so it can be replaced by Redis later.

## Login Lock

The default failed login policy is:

```text
5 failed password attempts -> lock account for 15 minutes
successful login -> reset failedLoginAttempts and lockedUntil
```

Configuration:

```env
AUTH_MAX_LOGIN_ATTEMPTS=5
AUTH_LOCK_DURATION_MINUTES=15
```
