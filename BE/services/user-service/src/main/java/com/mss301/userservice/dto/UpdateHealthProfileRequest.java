package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.ActivityLevel;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Update Health Profile Request")
@Builder
public record UpdateHealthProfileRequest(
        @DecimalMin(value = "50.0")
        @DecimalMax(value = "250.0")
        BigDecimal height,

        @DecimalMin(value = "10.0")
        @DecimalMax(value = "300.0")
        BigDecimal weight,

        ActivityLevel activityLevel
) {
}
