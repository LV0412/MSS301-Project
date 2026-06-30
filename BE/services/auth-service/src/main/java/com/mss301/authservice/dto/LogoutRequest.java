package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
@Schema(description = "Logout request")
public record LogoutRequest(
        @NotBlank
        @Schema(description = "Refresh token to revoke", example = "X7PV0vlb0M9tDksW07fxa7P6hdcQmTX6RLTiw6ih9s4")
        String refreshToken
) {
}
