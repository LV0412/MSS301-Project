package com.mss301.userservice.dto;

import lombok.Builder;

@Builder
public record DietPreferenceResponse(
        Long preferenceId,
        Long userId,
        String dietType
) {
}
