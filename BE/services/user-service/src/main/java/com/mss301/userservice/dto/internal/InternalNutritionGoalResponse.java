package com.mss301.userservice.dto.internal;

import com.mss301.userservice.entity.GoalType;
import com.mss301.userservice.entity.NutritionGoalOutdatedReason;
import com.mss301.userservice.entity.NutritionGoalStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Internal Nutrition Goal Response")
@Builder
public record InternalNutritionGoalResponse(
        GoalType goalType,
        BigDecimal targetWeight,
        Integer durationWeeks,
        BigDecimal weeklyRateKg,
        BigDecimal recommendedCalories,
        BigDecimal dailyCaloriesGoal,
        BigDecimal calories,
        BigDecimal protein,
        BigDecimal carbs,
        BigDecimal fat,
        Boolean goalConfigured,
        NutritionGoalStatus status,
        NutritionGoalOutdatedReason outdatedReason
) {
}
