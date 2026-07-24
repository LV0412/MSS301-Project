package com.mss301.userservice.client;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

public record AiGeneratedMealPlanEntry(
        @JsonProperty("recipe_id")
        Long recipeId,
        @JsonProperty("meal_type")
        String mealType,
        @JsonProperty("scheduled_time")
        LocalTime scheduledTime,
        @JsonProperty("recipe_name")
        String recipeName,
        @JsonProperty("target_calories_for_slot")
        Integer targetCaloriesForSlot,
        @JsonProperty("actual_calories")
        Integer actualCalories,
        @JsonProperty("actual_protein")
        Integer actualProtein,
        @JsonProperty("actual_carbs")
        Integer actualCarbs,
        @JsonProperty("actual_fat")
        Integer actualFat,
        @JsonProperty("image_url")
        String imageUrl,
        @JsonProperty("suitability_score")
        BigDecimal suitabilityScore,
        String reason,
        List<String> warnings,
        @JsonProperty("is_manually_swapped")
        boolean manuallySwapped
) {
}
