package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Nutrition Goal Response")
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
