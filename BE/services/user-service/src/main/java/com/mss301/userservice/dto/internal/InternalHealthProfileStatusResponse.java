package com.mss301.userservice.dto.internal;

import lombok.Builder;

@Builder
public record InternalHealthProfileStatusResponse(
        Long userId,
        HealthProfileCompletionStatus status
) {
}
