package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.ActivityLevel;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Health Profile Response")
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
