package com.mss301.authservice.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
public record LoginRequest(
        @NotBlank
        @Email
        String email,

        @NotBlank
        @Size(max = 72)
        String password,

        @Size(max = 255)
        String deviceInfo
) {
}
