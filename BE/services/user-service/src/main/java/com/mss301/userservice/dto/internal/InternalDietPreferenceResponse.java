package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import lombok.Builder;

@Schema(description = "Internal Diet Preference Response")
@Builder
public record InternalDietPreferenceResponse(
        Long preferenceId,
        String dietType
) {
}
