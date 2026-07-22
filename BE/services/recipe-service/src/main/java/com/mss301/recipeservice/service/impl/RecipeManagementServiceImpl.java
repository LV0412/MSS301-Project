package com.mss301.recipeservice.service.impl;

import com.mss301.recipeservice.dto.CatalogDtos.NutritionRequest;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeIngredientRequest;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeRequest;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeStepRequest;
import com.mss301.recipeservice.dto.RecipeSearchCriteria;
import com.mss301.recipeservice.entity.Category;
import com.mss301.recipeservice.entity.DietType;
import com.mss301.recipeservice.entity.Ingredient;
import com.mss301.recipeservice.entity.NutritionInfo;
import com.mss301.recipeservice.entity.Recipe;
import com.mss301.recipeservice.entity.RecipeIngredient;
import com.mss301.recipeservice.entity.RecipeIngredientId;
import com.mss301.recipeservice.entity.RecipeStep;
import com.mss301.recipeservice.exception.BusinessRuleViolationException;
import com.mss301.recipeservice.exception.ResourceNotFoundException;
import com.mss301.recipeservice.mapper.RecipeMapper;
import com.mss301.recipeservice.repository.IngredientRepository;
import com.mss301.recipeservice.repository.RecipeRepository;
import com.mss301.recipeservice.repository.RecipeSpecifications;
import com.mss301.recipeservice.service.RecipeManagementService;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional
public class RecipeManagementServiceImpl implements RecipeManagementService {

    private final RecipeRepository recipeRepository;
    private final IngredientRepository ingredientRepository;
    private final CategoryServiceImpl categoryService;
    private final RecipeMapper mapper;

    public RecipeResponse create(RecipeRequest request) {
        validateRequest(request);
        Category category = categoryService.find(request.categoryId());
        Recipe recipe = Recipe.builder().build();
        applyScalarFields(recipe, request, category);
        recipe = recipeRepository.saveAndFlush(recipe);
        attachChildren(recipe, request);
        return mapper.toResponse(recipeRepository.saveAndFlush(recipe));
    }

    @Transactional(readOnly = true)
    public RecipeResponse get(Long recipeId) {
        return mapper.toResponse(find(recipeId));
    }

    @Transactional(readOnly = true)
    public Page<RecipeResponse> search(RecipeSearchCriteria criteria, Pageable pageable) {
        validateSearch(criteria);
        return recipeRepository.findAll(RecipeSpecifications.matches(criteria), pageable).map(mapper::toResponse);
    }

    public RecipeResponse update(Long recipeId, RecipeRequest request) {
        validateRequest(request);
        Recipe recipe = find(recipeId);
        Category category = categoryService.find(request.categoryId());

        recipe.getRecipeIngredients().clear();
        recipe.getSteps().clear();
        recipeRepository.saveAndFlush(recipe);

        applyScalarFields(recipe, request, category);
        attachChildren(recipe, request);
        return mapper.toResponse(recipeRepository.saveAndFlush(recipe));
    }

    public void delete(Long recipeId) {
        recipeRepository.delete(find(recipeId));
    }

    private Recipe find(Long recipeId) {
        return recipeRepository.findById(recipeId)
                .orElseThrow(() -> new ResourceNotFoundException("Recipe", recipeId));
    }

    private void applyScalarFields(Recipe recipe, RecipeRequest request, Category category) {
        recipe.setCategory(category);
        recipe.setTitle(request.title().trim());
        recipe.setDescription(request.description().trim());
        recipe.setImageUrl(trimToNull(request.imageUrl()));
        recipe.setPreparationTime(request.preparationTime());
        recipe.setCookTime(request.cookTime());
        recipe.setDifficulty(request.difficulty());
        recipe.setServings(request.servings());
        Set<DietType> dietTypes = request.dietTypes() == null || request.dietTypes().isEmpty()
                ? EnumSet.of(DietType.NORMAL)
                : EnumSet.copyOf(request.dietTypes());
        recipe.getDietTypes().clear();
        recipe.getDietTypes().addAll(dietTypes);
    }

    private void attachChildren(Recipe recipe, RecipeRequest request) {
        Set<Long> ingredientIds = request.ingredients().stream()
                .map(RecipeIngredientRequest::ingredientId)
                .collect(Collectors.toCollection(LinkedHashSet::new));
        Map<Long, Ingredient> ingredients = ingredientRepository.findAllById(ingredientIds).stream()
                .collect(Collectors.toMap(Ingredient::getIngredientId, Function.identity()));
        if (ingredients.size() != ingredientIds.size()) {
            Long missing = ingredientIds.stream().filter(id -> !ingredients.containsKey(id)).findFirst().orElse(null);
            throw new ResourceNotFoundException("Ingredient", missing);
        }

        Set<RecipeIngredient> recipeIngredients = request.ingredients().stream()
                .map(item -> RecipeIngredient.builder()
                        .id(new RecipeIngredientId(recipe.getRecipeId(), item.ingredientId()))
                        .recipe(recipe)
                        .ingredient(ingredients.get(item.ingredientId()))
                        .quantity(item.quantity())
                        .unit(item.unit().trim())
                        .build())
                .collect(Collectors.toCollection(LinkedHashSet::new));
        recipe.getRecipeIngredients().addAll(recipeIngredients);

        List<RecipeStep> steps = request.steps().stream()
                .sorted(Comparator.comparingInt(RecipeStepRequest::stepOrder))
                .map(step -> RecipeStep.builder()
                        .recipe(recipe)
                        .stepOrder(step.stepOrder())
                        .instruction(step.instruction().trim())
                        .build())
                .collect(Collectors.toCollection(ArrayList::new));
        recipe.getSteps().addAll(steps);

        NutritionRequest input = request.nutrition();
        NutritionInfo nutrition = recipe.getNutrition();
        if (nutrition == null) {
            nutrition = NutritionInfo.builder().recipe(recipe).build();
            recipe.setNutrition(nutrition);
        }
        nutrition.setServingSizeGrams(input.servingSizeGrams());
        nutrition.setCalories(input.calories());
        nutrition.setProtein(input.protein());
        nutrition.setFat(input.fat());
        nutrition.setSaturatedFat(input.saturatedFat());
        nutrition.setTransFat(input.transFat());
        nutrition.setCholesterol(input.cholesterol());
        nutrition.setCarbs(input.carbs());
        nutrition.setFiber(input.fiber());
        nutrition.setSugar(input.sugar());
        nutrition.setSodium(input.sodium());
        nutrition.setPotassium(input.potassium());
        nutrition.setVitaminA(input.vitaminA());
        nutrition.setVitaminD(input.vitaminD());
        nutrition.setVitaminE(input.vitaminE());
        nutrition.setVitaminK(input.vitaminK());
        nutrition.setVitaminB1(input.vitaminB1());
        nutrition.setVitaminB2(input.vitaminB2());
        nutrition.setVitaminB3(input.vitaminB3());
        nutrition.setVitaminB6(input.vitaminB6());
        nutrition.setVitaminB9(input.vitaminB9());
        nutrition.setVitaminB12(input.vitaminB12());
        nutrition.setVitaminC(input.vitaminC());
        nutrition.setCalcium(input.calcium());
        nutrition.setIron(input.iron());
    }

    private void validateRequest(RecipeRequest request) {
        if (request == null) {
            throw new BusinessRuleViolationException("Recipe request is required");
        }
        if (request.categoryId() == null) {
            throw new BusinessRuleViolationException("A recipe must belong to a category");
        }
        if (!StringUtils.hasText(request.title())) {
            throw new BusinessRuleViolationException("Recipe title is required");
        }
        if (!StringUtils.hasText(request.description())) {
            throw new BusinessRuleViolationException("Recipe description is required");
        }
        if (request.ingredients() == null || request.ingredients().isEmpty()) {
            throw new BusinessRuleViolationException("A recipe must contain at least one ingredient");
        }
        if (request.steps() == null || request.steps().isEmpty()) {
            throw new BusinessRuleViolationException("A recipe must contain at least one step");
        }
        if (request.nutrition() == null) {
            throw new BusinessRuleViolationException("A recipe must contain nutrition information");
        }
        if (request.ingredients().stream().anyMatch(item -> item == null || item.ingredientId() == null)) {
            throw new BusinessRuleViolationException("Every recipe ingredient must reference an ingredient");
        }
        if (request.steps().stream().anyMatch(step -> step == null || step.stepOrder() == null)) {
            throw new BusinessRuleViolationException("Every recipe step must define a step order");
        }

        long ingredientCount = request.ingredients().stream()
                .map(RecipeIngredientRequest::ingredientId).distinct().count();
        if (ingredientCount != request.ingredients().size()) {
            throw new BusinessRuleViolationException("A recipe cannot contain the same ingredient more than once");
        }

        List<Integer> orders = request.steps().stream()
                .map(RecipeStepRequest::stepOrder).sorted().toList();
        List<Integer> expected = IntStream.rangeClosed(1, orders.size()).boxed().toList();
        if (!orders.equals(expected)) {
            throw new BusinessRuleViolationException("Recipe stepOrder values must be unique and consecutive from 1");
        }
    }

    private void validateSearch(RecipeSearchCriteria criteria) {
        if (isNegative(criteria.minCalories()) || isNegative(criteria.maxCalories())) {
            throw new BusinessRuleViolationException("Calorie filters cannot be negative");
        }
        if (criteria.minCalories() != null && criteria.maxCalories() != null
                && criteria.minCalories().compareTo(criteria.maxCalories()) > 0) {
            throw new BusinessRuleViolationException("minCalories cannot exceed maxCalories");
        }
    }

    private boolean isNegative(BigDecimal value) {
        return value != null && value.signum() < 0;
    }

    private String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
