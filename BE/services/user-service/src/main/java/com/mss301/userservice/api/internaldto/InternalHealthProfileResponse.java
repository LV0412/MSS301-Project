package com.mss301.userservice.api.internaldto;

import com.mss301.userservice.domain.ActivityLevel;
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
