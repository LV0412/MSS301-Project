package com.mss301.userservice.api.dto;

import lombok.Builder;

@Builder
public record DietPreferenceResponse(
        Long preferenceId,
        Long userId,
        String dietType
) {
}
