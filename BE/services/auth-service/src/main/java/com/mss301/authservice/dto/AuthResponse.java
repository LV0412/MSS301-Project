package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "Authentication response")
public record AuthResponse(
        @Schema(description = "JWT access token", example = "eyJhbGciOiJIUzI1NiJ9...")
        String accessToken,

        @Schema(description = "Refresh token. Store securely on the client.", example = "X7PV0vlb0M9tDksW07fxa7P6hdcQmTX6RLTiw6ih9s4")
        String refreshToken,

        @Schema(description = "Token type", example = "Bearer")
        String tokenType,

        @Schema(description = "Access token lifetime in seconds", example = "900")
        Long expiresIn,

        AccountResponse account
) {
}
