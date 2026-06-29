package com.mss301.authservice.dto;

import lombok.Builder;

@Builder
public record MessageResponse(
        String message
) {
}
