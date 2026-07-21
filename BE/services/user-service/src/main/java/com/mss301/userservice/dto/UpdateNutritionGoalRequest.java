package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.mss301.userservice.entity.GoalType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Update Nutrition Goal Request")
@Builder
public record UpdateNutritionGoalRequest(
        GoalType goalType,

        @DecimalMin(value = "10.0")
        @DecimalMax(value = "300.0")
        BigDecimal targetWeight,

        @Min(1)
        @Max(520)
        Integer durationWeeks,

        @DecimalMin(value = "0.0")
        @DecimalMax(value = "1.0")
        BigDecimal weeklyRateKg,

        @JsonAlias("calories")
        @DecimalMin(value = "0.0", inclusive = false)
        BigDecimal dailyCaloriesGoal,

        @DecimalMin(value = "0.0")
        BigDecimal protein,

        @DecimalMin(value = "0.0")
        BigDecimal carbs,

        @DecimalMin(value = "0.0")
        BigDecimal fat
) {
}
