package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.ActivityLevel;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Create Health Profile Request")
@Builder
public record CreateHealthProfileRequest(
        @NotNull
        @DecimalMin(value = "50.0")
        @DecimalMax(value = "250.0")
        BigDecimal height,

        @NotNull
        @DecimalMin(value = "10.0")
        @DecimalMax(value = "300.0")
        BigDecimal weight,

        @NotNull
        ActivityLevel activityLevel
) {
}
