package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
@Schema(description = "Refresh token request")
public record RefreshTokenRequest(
        @NotBlank
        @Schema(description = "Refresh token issued by login or refresh endpoint", example = "X7PV0vlb0M9tDksW07fxa7P6hdcQmTX6RLTiw6ih9s4")
        String refreshToken
) {
}
