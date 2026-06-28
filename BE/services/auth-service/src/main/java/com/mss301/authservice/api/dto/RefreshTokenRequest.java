package com.mss301.authservice.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
public record RefreshTokenRequest(
        @NotBlank
        String refreshToken,

        @Size(max = 255)
        String deviceInfo
) {
}
