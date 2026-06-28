package com.mss301.userservice.api.internaldto;

import lombok.Builder;

@Builder
public record InternalDietPreferenceResponse(
        Long preferenceId,
        String dietType
) {
}
