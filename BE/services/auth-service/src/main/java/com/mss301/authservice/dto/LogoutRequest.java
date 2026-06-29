package com.mss301.authservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
public record LogoutRequest(
        @NotBlank
        String refreshToken
) {
}
