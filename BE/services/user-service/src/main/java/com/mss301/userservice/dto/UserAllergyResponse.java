package com.mss301.userservice.dto;

import com.mss301.userservice.entity.AllergySeverity;
import lombok.Builder;

@Builder
public record UserAllergyResponse(
        Long allergyId,
        Long userId,
        Long allergenId,
        AllergySeverity severity
) {
}
