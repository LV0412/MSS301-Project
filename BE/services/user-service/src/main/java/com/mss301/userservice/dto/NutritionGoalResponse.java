package com.mss301.userservice.dto;

import com.mss301.userservice.entity.GoalType;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;
import lombok.Builder;

@Schema(description = "Nutrition Goal Response")
@Builder
public record NutritionGoalResponse(
        Long goalId,
        Long userId,
        Integer goalVersion,
        GoalType goalType,
        BigDecimal targetWeight,
        Integer durationWeeks,
        BigDecimal weeklyRateKg,
        BigDecimal recommendedCalories,
        BigDecimal dailyCaloriesGoal,
        BigDecimal protein,
        BigDecimal carbs,
        BigDecimal fat,
        List<String> warnings,
        Boolean goalConfigured
) {
}
