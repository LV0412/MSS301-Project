package com.mss301.authservice.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
public record ResetPasswordRequest(
        @NotBlank
        String resetToken,

        @NotBlank
        @Size(min = 8, max = 72)
        String newPassword
) {
}
