package com.mss301.userservice.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import lombok.Builder;

@Builder
public record MealPlanResponse(
        Long mealPlanId,
        Long userId,
        Long nutritionGoalId,
        Integer nutritionGoalVersion,
        LocalDate planDate,
        String title,
        String status,
        BigDecimal matchScore,
        List<String> warnings,
        List<MealPlanEntryResponse> entries
) {
}
