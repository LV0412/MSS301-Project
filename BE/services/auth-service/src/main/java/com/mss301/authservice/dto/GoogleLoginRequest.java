package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
@Schema(description = "Google login request")
public record GoogleLoginRequest(
        @NotBlank
        @Schema(description = "Google ID token returned by the client SDK", example = "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...")
        String idToken,

        @Schema(description = "Current LOCAL account password. Required only when linking Google to an existing LOCAL email.")
        String password
) {
}
