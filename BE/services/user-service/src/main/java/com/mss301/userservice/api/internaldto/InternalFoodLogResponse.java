package com.mss301.userservice.api.internaldto;

import com.mss301.userservice.domain.MealType;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Builder;

@Builder
public record InternalFoodLogResponse(
        Long logId,
        Long recipeId,
        BigDecimal quantity,
        MealType mealType,
        LocalDate logDate
) {
}
