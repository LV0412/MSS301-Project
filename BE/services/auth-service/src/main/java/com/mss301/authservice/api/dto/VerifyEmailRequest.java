package com.mss301.authservice.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Builder;

@Builder
public record VerifyEmailRequest(
        @NotBlank
        @Email
        String email,

        @NotBlank
        @Pattern(regexp = "\\d{6}")
        String otpCode
) {
}
