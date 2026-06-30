package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Internal Nutrition Goal Response")
@Builder
public record InternalNutritionGoalResponse(
        BigDecimal calories,
        BigDecimal protein,
        BigDecimal carbs,
        BigDecimal fat
) {
}
