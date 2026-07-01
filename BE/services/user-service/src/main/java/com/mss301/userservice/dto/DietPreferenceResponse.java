package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import lombok.Builder;

@Schema(description = "Diet Preference Response")
@Builder
public record DietPreferenceResponse(
        Long preferenceId,
        Long userId,
        String dietType
) {
}
