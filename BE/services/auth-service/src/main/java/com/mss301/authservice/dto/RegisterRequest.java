package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
@Schema(description = "Register request")
public record RegisterRequest(
        @NotBlank
        @Email
        @Size(max = 255)
        @Schema(description = "Account email", example = "test@example.com")
        String email,

        @NotBlank
        @Size(min = 8, max = 100)
        @Schema(description = "Plain text password. It will be stored as BCrypt hash.", example = "Password@123")
        String password,

        @NotBlank
        @Size(max = 255)
        @Schema(description = "User display name", example = "Test User")
        String fullName
) {
}
