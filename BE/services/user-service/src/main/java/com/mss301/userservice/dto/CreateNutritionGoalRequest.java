package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Builder;

@Schema(description = "Create Nutrition Goal Request")
@Builder
public record CreateNutritionGoalRequest(
        @NotNull
        @DecimalMin(value = "0.0", inclusive = false)
        BigDecimal calories,

        @NotNull
        @DecimalMin(value = "0.0")
        BigDecimal protein,

        @NotNull
        @DecimalMin(value = "0.0")
        BigDecimal carbs,

        @NotNull
        @DecimalMin(value = "0.0")
        BigDecimal fat
) {
}
