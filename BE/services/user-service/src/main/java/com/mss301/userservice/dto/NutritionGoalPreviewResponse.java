package com.mss301.userservice.dto;

import com.mss301.userservice.entity.GoalType;
import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;
import java.util.List;
import lombok.Builder;

@Schema(description = "Calculated nutrition goal preview without persistence")
@Builder
public record NutritionGoalPreviewResponse(
        GoalType goalType,
        BigDecimal targetWeight,
        Integer durationWeeks,
        BigDecimal weeklyRateKg,
        BigDecimal bmr,
        BigDecimal recommendedCalories,
        BigDecimal dailyCaloriesGoal,
        BigDecimal protein,
        BigDecimal carbs,
        BigDecimal fat,
        List<String> warnings
) {
}
