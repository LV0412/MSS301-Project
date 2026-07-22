package com.mss301.recipeservice.dto;

import com.mss301.recipeservice.entity.DietType;
import java.math.BigDecimal;
import java.util.Set;

public record RecipeSearchCriteria(
        String query,
        Long categoryId,
        Set<Long> ingredientIds,
        String ingredient,
        BigDecimal minCalories,
        BigDecimal maxCalories,
        DietType dietType,
        Set<Long> excludedAllergenIds) {
}
