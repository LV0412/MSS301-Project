package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.MealType;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Builder;

@Schema(description = "Internal Food Log Response")
@Builder
public record InternalFoodLogResponse(
        Long logId,
        Long recipeId,
        BigDecimal quantity,
        MealType mealType,
        LocalDate logDate
) {
}
