package com.mss301.recipeservice.application;

import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.CategoryResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.IngredientResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.NutritionResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeIngredientResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeStepResponse;
import com.mss301.recipeservice.domain.Allergen;
import com.mss301.recipeservice.domain.Category;
import com.mss301.recipeservice.domain.Ingredient;
import com.mss301.recipeservice.domain.NutritionInfo;
import com.mss301.recipeservice.domain.Recipe;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
public class RecipeMapper {

    public CategoryResponse toResponse(Category category) {
        return new CategoryResponse(category.getCategoryId(), category.getName(), category.getDescription());
    }

    public AllergenResponse toResponse(Allergen allergen) {
        return new AllergenResponse(allergen.getAllergenId(), allergen.getName());
    }

    public IngredientResponse toResponse(Ingredient ingredient) {
        Set<AllergenResponse> allergens = ingredient.getAllergens().stream()
                .sorted(Comparator.comparing(Allergen::getName, String.CASE_INSENSITIVE_ORDER))
                .map(this::toResponse)
                .collect(java.util.stream.Collectors.toCollection(LinkedHashSet::new));
        return new IngredientResponse(ingredient.getIngredientId(), ingredient.getName(), allergens);
    }

    public RecipeResponse toResponse(Recipe recipe) {
        List<RecipeIngredientResponse> ingredients = recipe.getRecipeIngredients().stream()
                .sorted(Comparator.comparing(item -> item.getIngredient().getName(), String.CASE_INSENSITIVE_ORDER))
                .map(item -> new RecipeIngredientResponse(
                        item.getIngredient().getIngredientId(),
                        item.getIngredient().getName(),
                        item.getQuantity(),
                        item.getUnit(),
                        toResponse(item.getIngredient()).allergens()))
                .toList();

        List<RecipeStepResponse> steps = recipe.getSteps().stream()
                .sorted(Comparator.comparingInt(step -> step.getStepOrder()))
                .map(step -> new RecipeStepResponse(step.getStepId(), step.getStepOrder(), step.getInstruction()))
                .toList();

        NutritionInfo nutrition = recipe.getNutrition();
        NutritionResponse nutritionResponse = new NutritionResponse(
                nutrition.getNutritionId(), nutrition.getCalories(), nutrition.getProtein(), nutrition.getFat(),
                nutrition.getCarbs(), nutrition.getFiber(), nutrition.getSugar(), nutrition.getSodium());

        return new RecipeResponse(
                recipe.getRecipeId(), toResponse(recipe.getCategory()), recipe.getTitle(), recipe.getDescription(),
                recipe.getImageUrl(), recipe.getPreparationTime(), recipe.getCookTime(), recipe.getDifficulty(),
                recipe.getServings(), Set.copyOf(recipe.getDietTypes()), ingredients, steps, nutritionResponse,
                recipe.getCreatedAt(), recipe.getUpdatedAt());
    }
}
