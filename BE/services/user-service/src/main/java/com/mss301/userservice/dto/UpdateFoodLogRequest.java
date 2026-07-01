package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.MealType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Builder;

@Schema(description = "Update Food Log Request")
@Builder
public record UpdateFoodLogRequest(
        @NotNull
        @Positive
        Long recipeId,

        @NotNull
        @DecimalMin(value = "0.0", inclusive = false)
        BigDecimal quantity,

        @NotNull
        MealType mealType,

        @NotNull
        LocalDate logDate
) {
}
