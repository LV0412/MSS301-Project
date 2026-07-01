package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;

@Builder
@Schema(description = "Message response")
public record MessageResponse(
        @Schema(description = "Human-readable response message", example = "Operation completed successfully.")
        String message
) {
}
