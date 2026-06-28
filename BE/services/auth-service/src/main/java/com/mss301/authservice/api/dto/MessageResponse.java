package com.mss301.authservice.api.dto;

import lombok.Builder;

@Builder
public record MessageResponse(String message) {
}
