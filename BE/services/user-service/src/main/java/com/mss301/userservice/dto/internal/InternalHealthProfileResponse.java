package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.ActivityLevel;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Internal Health Profile Response")
@Builder
public record InternalHealthProfileResponse(
        BigDecimal height,
        BigDecimal weight,
        ActivityLevel activityLevel,
        BigDecimal bmi
) {
}
