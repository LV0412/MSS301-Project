package com.mss301.userservice.api.dto;

import com.mss301.userservice.domain.MealType;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Builder;

@Builder
public record FoodLogResponse(
        Long logId,
        Long userId,
        Long recipeId,
        BigDecimal quantity,
        MealType mealType,
        LocalDate logDate
) {
}
