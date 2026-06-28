package com.mss301.userservice.dto.internal;

import com.mss301.userservice.entity.AllergySeverity;
import lombok.Builder;

@Builder
public record InternalUserAllergyResponse(
        Long allergyId,
        Long allergenId,
        AllergySeverity severity
) {
}
