# Auth Service Error Codes

All error responses include a stable `code` field. Clients should branch on `code`, not on `message`.

## Error Response Shape

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

## Auth Codes

| Code | HTTP | Description |
| --- | --- | --- |
| `INVALID_CREDENTIALS` | `401` | Email/password login failed. |
| `EMAIL_ALREADY_EXISTS` | `409` | Registration email already exists. |
| `ACCOUNT_NOT_FOUND` | `404` | Account does not exist. |
| `ACCOUNT_LOCKED` | `403` | Account is locked. |
| `ACCOUNT_DISABLED` | `403` | Account is not active. |
| `EMAIL_NOT_VERIFIED` | `403` | Account email is not verified. |
| `INVALID_VERIFICATION_TOKEN` | `400` | Email verification OTP is missing or invalid. |
| `VERIFICATION_TOKEN_EXPIRED` | `400` | Email verification OTP has expired. |
| `INVALID_RESET_TOKEN` | `400` | Password reset token is missing or invalid. |
| `RESET_TOKEN_ALREADY_USED` | `400` | Password reset token has already been consumed. |
| `RESET_TOKEN_EXPIRED` | `400` | Password reset token has expired. |
| `PASSWORD_CHANGE_UNAVAILABLE` | `400` | Password change is not available for the account provider. |
| `PASSWORD_MISMATCH` | `400` | New password and confirmation do not match. |
| `INVALID_CURRENT_PASSWORD` | `400` | Current password is incorrect. |
| `PASSWORD_REUSE_NOT_ALLOWED` | `400` | New password matches current password. |
| `AUTH_PROVIDER_MISMATCH` | `409` | Email is registered with another auth provider. |
| `GOOGLE_AUTH_UNAVAILABLE` | `503` | Google auth is not configured. |
| `INVALID_GOOGLE_TOKEN` | `401` | Google ID token is invalid or cannot be verified. |
| `GOOGLE_EMAIL_NOT_VERIFIED` | `401` | Google account email is not verified. |
| `INVALID_REFRESH_TOKEN` | `401` | Refresh token is invalid or revoked. |
| `REFRESH_TOKEN_EXPIRED` | `401` | Refresh token has expired. |
| `RATE_LIMIT_EXCEEDED` | `429` | Too many requests in the configured time window. |

## Common Codes

| Code | HTTP | Description |
| --- | --- | --- |
| `VALIDATION_ERROR` | `400` | Bean validation failed. Check `validationErrors`. |
| `MALFORMED_REQUEST` | `400` | Request body is malformed or contains an invalid enum value. |
| `DATA_INTEGRITY_VIOLATION` | `409` | Database constraint was violated. |
| `INVALID_PARAMETER` | `400` | Path/query parameter cannot be converted to the expected type. |
| `ACCESS_DENIED` | `403` | Authenticated user does not have access. |
| `UNAUTHORIZED` | `401` | Authentication is missing or invalid. |
| `INTERNAL_SERVER_ERROR` | `500` | Unexpected server error. |

## Client Handling Guidance

- Treat `401` as a signal to refresh token or return to login.
- Treat `403 EMAIL_NOT_VERIFIED` as a signal to show email verification UI.
- Treat `409 EMAIL_ALREADY_EXISTS` as a registration conflict.
- Treat `503 GOOGLE_AUTH_UNAVAILABLE` as a disabled Google login feature.
- Treat `429 RATE_LIMIT_EXCEEDED` as a temporary client backoff signal.
