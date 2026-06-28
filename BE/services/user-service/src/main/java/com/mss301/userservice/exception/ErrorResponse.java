package com.mss301.userservice.exception;

import java.time.LocalDateTime;
import java.util.Map;
import lombok.Builder;

@Builder
public record ErrorResponse(
        LocalDateTime timestamp,
        int status,
        String error,
        String message,
        String path,
        Map<String, String> validationErrors
) {
}
