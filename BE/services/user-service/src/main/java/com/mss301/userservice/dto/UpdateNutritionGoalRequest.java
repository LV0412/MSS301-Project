package com.mss301.userservice.dto;

import jakarta.validation.constraints.DecimalMin;
import java.math.BigDecimal;
import lombok.Builder;

@Builder
public record UpdateNutritionGoalRequest(
        @DecimalMin(value = "0.0", inclusive = false)
        BigDecimal calories,

        @DecimalMin(value = "0.0")
        BigDecimal protein,

        @DecimalMin(value = "0.0")
        BigDecimal carbs,

        @DecimalMin(value = "0.0")
        BigDecimal fat
) {
}
