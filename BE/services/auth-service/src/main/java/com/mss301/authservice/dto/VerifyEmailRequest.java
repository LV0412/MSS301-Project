package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
@Schema(description = "Verify email request")
public record VerifyEmailRequest(
        @NotBlank
        @Email
        @Size(max = 255)
        @Schema(description = "Account email", example = "test@example.com")
        String email,

        @NotBlank
        @Pattern(regexp = "\\d{6}", message = "OTP must contain exactly 6 digits")
        @Schema(description = "6-digit email verification OTP", example = "123456")
        String otp
) {
}
