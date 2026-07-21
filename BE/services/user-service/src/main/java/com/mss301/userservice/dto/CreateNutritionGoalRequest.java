package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.GoalType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Create Nutrition Goal Request")
@Builder
public record CreateNutritionGoalRequest(
        @NotNull
        GoalType goalType,

        @NotNull
        @DecimalMin(value = "10.0")
        @DecimalMax(value = "300.0")
        BigDecimal targetWeight,

        @NotNull
        @Min(1)
        @Max(520)
        Integer durationWeeks,

        @NotNull
        @DecimalMin(value = "0.0")
        @DecimalMax(value = "1.0")
        BigDecimal weeklyRateKg,

        @NotNull
        @DecimalMin(value = "0.0", inclusive = false)
        BigDecimal calories,

        @NotNull
        @DecimalMin(value = "0.0")
        BigDecimal protein,

        @NotNull
        @DecimalMin(value = "0.0")
        BigDecimal carbs,

        @NotNull
        @DecimalMin(value = "0.0")
        BigDecimal fat
) {
}
