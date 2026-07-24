package com.mss301.userservice.dto;

import com.mss301.userservice.entity.MealType;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import lombok.Builder;

@Builder
public record MealPlanEntryResponse(
        Long entryId,
        Long recipeId,
        MealType mealType,
        LocalTime scheduledTime,
        String recipeName,
        Integer targetCaloriesForSlot,
        Integer actualCalories,
        Integer actualProtein,
        Integer actualCarbs,
        Integer actualFat,
        String imageUrl,
        BigDecimal suitabilityScore,
        String reason,
        List<String> warnings,
        boolean manuallySwapped
) {
}
