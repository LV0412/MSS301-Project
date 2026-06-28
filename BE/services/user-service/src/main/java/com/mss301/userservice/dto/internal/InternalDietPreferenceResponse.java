package com.mss301.userservice.dto.internal;

import lombok.Builder;

@Builder
public record InternalDietPreferenceResponse(
        Long preferenceId,
        String dietType
) {
}
