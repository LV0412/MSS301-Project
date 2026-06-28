package com.mss301.userservice.api.dto;

import com.mss301.userservice.domain.ActivityLevel;
import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record HealthProfileResponse(
        Long profileId,
        Long userId,
        BigDecimal height,
        BigDecimal weight,
        ActivityLevel activityLevel,
        BigDecimal bmi
) {
}
