package com.mss301.userservice.api.dto;

import com.mss301.userservice.domain.AllergySeverity;
import lombok.Builder;

@Builder
public record UserAllergyResponse(
        Long allergyId,
        Long userId,
        Long allergenId,
        AllergySeverity severity
) {
}
