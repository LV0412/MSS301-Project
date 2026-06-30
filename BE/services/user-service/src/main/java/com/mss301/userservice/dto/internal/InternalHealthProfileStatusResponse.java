package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import lombok.Builder;

@Schema(description = "Internal Health Profile Status Response")
@Builder
public record InternalHealthProfileStatusResponse(
        Long userId,
        HealthProfileCompletionStatus status
) {
}
