package com.mss301.userservice.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record SwapMealPlanEntryRequest(
        @NotNull
        @Positive
        Long newRecipeId
) {
}
