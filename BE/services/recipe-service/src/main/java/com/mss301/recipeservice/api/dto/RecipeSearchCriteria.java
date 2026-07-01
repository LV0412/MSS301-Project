package com.mss301.recipeservice.api.dto;

import com.mss301.recipeservice.domain.DietType;
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
