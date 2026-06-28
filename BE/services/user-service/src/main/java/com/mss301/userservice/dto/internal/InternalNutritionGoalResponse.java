package com.mss301.userservice.dto.internal;

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
