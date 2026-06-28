package com.mss301.userservice.api.dto;

import com.mss301.userservice.domain.ActivityLevel;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record UpdateHealthProfileRequest(
        @DecimalMin(value = "1.0")
        @DecimalMax(value = "300.0")
        BigDecimal height,

        @DecimalMin(value = "1.0")
        @DecimalMax(value = "500.0")
        BigDecimal weight,

        ActivityLevel activityLevel
) {
}
