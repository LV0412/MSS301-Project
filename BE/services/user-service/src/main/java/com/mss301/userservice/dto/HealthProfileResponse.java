package com.mss301.userservice.dto;

import com.mss301.userservice.entity.ActivityLevel;
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
