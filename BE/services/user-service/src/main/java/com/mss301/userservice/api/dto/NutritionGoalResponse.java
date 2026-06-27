package com.mss301.userservice.api.dto;

import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record NutritionGoalResponse(
        Long goalId,
        Long userId,
        BigDecimal calories,
        BigDecimal protein,
        BigDecimal carbs,
        BigDecimal fat
) {
}
