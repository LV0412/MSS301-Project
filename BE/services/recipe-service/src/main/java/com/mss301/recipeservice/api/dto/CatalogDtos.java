package com.mss301.recipeservice.api.dto;

import com.mss301.recipeservice.domain.DietType;
import com.mss301.recipeservice.domain.Difficulty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

public final class CatalogDtos {

    private CatalogDtos() {
    }

    public record CategoryRequest(
            @NotBlank @Size(max = 100) String name,
            @Size(max = 1000) String description) {
    }

    public record CategoryResponse(Long categoryId, String name, String description) {
    }

    public record AllergenRequest(@NotBlank @Size(max = 100) String name) {
    }

    public record AllergenResponse(Long allergenId, String name) {
    }

    public record IngredientRequest(
            @NotBlank @Size(max = 150) String name,
            Set<@Positive Long> allergenIds) {
    }

    public record IngredientResponse(
            Long ingredientId,
            String name,
            Set<AllergenResponse> allergens) {
    }

    public record RecipeIngredientRequest(
            @NotNull @Positive Long ingredientId,
            @NotNull @DecimalMin(value = "0.0", inclusive = false) BigDecimal quantity,
            @NotBlank @Size(max = 50) String unit) {
    }

    public record RecipeIngredientResponse(
            Long ingredientId,
            String name,
            BigDecimal quantity,
            String unit,
            Set<AllergenResponse> allergens) {
    }

    public record RecipeStepRequest(
            @NotNull @Positive Integer stepOrder,
            @NotBlank String instruction) {
    }

    public record RecipeStepResponse(Long stepId, Integer stepOrder, String instruction) {
    }

    public record NutritionRequest(
            @NotNull @PositiveOrZero BigDecimal calories,
            @NotNull @PositiveOrZero BigDecimal protein,
            @NotNull @PositiveOrZero BigDecimal fat,
            @NotNull @PositiveOrZero BigDecimal carbs,
            @NotNull @PositiveOrZero BigDecimal fiber,
            @NotNull @PositiveOrZero BigDecimal sugar,
            @NotNull @PositiveOrZero BigDecimal sodium) {
    }

    public record NutritionResponse(
            Long nutritionId,
            BigDecimal calories,
            BigDecimal protein,
            BigDecimal fat,
            BigDecimal carbs,
            BigDecimal fiber,
            BigDecimal sugar,
            BigDecimal sodium) {
    }

    public record RecipeRequest(
            @NotNull @Positive Long categoryId,
            @NotBlank @Size(max = 255) String title,
            @NotBlank String description,
            @Size(max = 2048) String imageUrl,
            @NotNull @PositiveOrZero Integer preparationTime,
            @NotNull @PositiveOrZero Integer cookTime,
            @NotNull Difficulty difficulty,
            @NotNull @Positive Integer servings,
            Set<@NotNull DietType> dietTypes,
            @NotEmpty List<@Valid RecipeIngredientRequest> ingredients,
            @NotEmpty List<@Valid RecipeStepRequest> steps,
            @NotNull @Valid NutritionRequest nutrition) {
    }

    public record RecipeResponse(
            Long recipeId,
            CategoryResponse category,
            String title,
            String description,
            String imageUrl,
            Integer preparationTime,
            Integer cookTime,
            Difficulty difficulty,
            Integer servings,
            Set<DietType> dietTypes,
            List<RecipeIngredientResponse> ingredients,
            List<RecipeStepResponse> steps,
            NutritionResponse nutrition,
            LocalDateTime createdAt,
            LocalDateTime updatedAt) {
    }
}
