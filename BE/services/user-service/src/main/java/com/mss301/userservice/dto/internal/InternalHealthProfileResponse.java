package com.mss301.userservice.dto.internal;

import com.mss301.userservice.entity.ActivityLevel;
import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record InternalHealthProfileResponse(
        BigDecimal height,
        BigDecimal weight,
        ActivityLevel activityLevel,
        BigDecimal bmi
) {
}
