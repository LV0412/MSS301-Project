package com.mss301.userservice.api.internaldto;

import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record InternalNutritionGoalResponse(
        BigDecimal calories,
        BigDecimal protein,
        BigDecimal carbs,
        BigDecimal fat
) {
}
