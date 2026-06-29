package com.mss301.authservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
public record ChangePasswordRequest(
        @NotBlank
        @Size(max = 100)
        String currentPassword,

        @NotBlank
        @Size(min = 8, max = 100)
        String newPassword,

        @NotBlank
        @Size(min = 8, max = 100)
        String confirmPassword
) {
}
