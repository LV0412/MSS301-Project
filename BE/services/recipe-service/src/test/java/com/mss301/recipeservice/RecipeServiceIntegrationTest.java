package com.mss301.recipeservice;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.CategoryRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.IngredientRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.NutritionRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeIngredientRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeStepRequest;
import com.mss301.recipeservice.api.dto.RecipeSearchCriteria;
import com.mss301.recipeservice.application.AllergenService;
import com.mss301.recipeservice.application.CategoryService;
import com.mss301.recipeservice.application.IngredientService;
import com.mss301.recipeservice.application.RecipeManagementService;
import com.mss301.recipeservice.domain.DietType;
import com.mss301.recipeservice.domain.Difficulty;
import com.mss301.recipeservice.exception.BusinessRuleViolationException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class RecipeServiceIntegrationTest {

    @Autowired private CategoryService categoryService;
    @Autowired private AllergenService allergenService;
    @Autowired private IngredientService ingredientService;
    @Autowired private RecipeManagementService recipeService;

    private Long categoryId;
    private Long peanutAllergenId;
    private Long peanutIngredientId;

    @BeforeEach
    void setUpCatalog() {
        categoryId = categoryService.create(new CategoryRequest("Lunch", "Main meals")).categoryId();
        peanutAllergenId = allergenService.create(new AllergenRequest("Peanut")).allergenId();
        peanutIngredientId = ingredientService.create(
                new IngredientRequest("Peanut", Set.of(peanutAllergenId))).ingredientId();
    }

    @Test
    void createsCompleteRecipeAggregate() {
        RecipeResponse created = recipeService.create(validRequest(Set.of(DietType.VEGAN)));

        assertThat(created.recipeId()).isNotNull();
        assertThat(created.category().categoryId()).isEqualTo(categoryId);
        assertThat(created.ingredients()).hasSize(1);
        assertThat(created.steps()).extracting("stepOrder").containsExactly(1, 2);
        assertThat(created.nutrition().calories()).isEqualByComparingTo("420.00");
        assertThat(created.dietTypes()).containsExactly(DietType.VEGAN);
    }

    @Test
    void excludesRecipesContainingAUserAllergen() {
        recipeService.create(validRequest(Set.of(DietType.VEGAN)));

        var safeResults = recipeService.search(new RecipeSearchCriteria(
                null, null, null, null, null, null, null, Set.of(peanutAllergenId)),
                PageRequest.of(0, 10));
        var veganResults = recipeService.search(new RecipeSearchCriteria(
                null, null, null, null, null, null, DietType.VEGAN, null),
                PageRequest.of(0, 10));

        assertThat(safeResults).isEmpty();
        assertThat(veganResults).hasSize(1);
    }

    @Test
    void rejectsNonConsecutiveRecipeSteps() {
        RecipeRequest invalid = new RecipeRequest(
                categoryId, "Peanut noodles", "Quick noodles", null, 5, 10, Difficulty.EASY, 1,
                Set.of(DietType.VEGAN),
                List.of(new RecipeIngredientRequest(peanutIngredientId, new BigDecimal("50"), "g")),
                List.of(
                        new RecipeStepRequest(1, "Boil noodles"),
                        new RecipeStepRequest(3, "Add peanut")),
                nutrition());

        assertThatThrownBy(() -> recipeService.create(invalid))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("consecutive");
    }

    @Test
    void replacesNestedRecipeDataOnUpdate() {
        RecipeResponse created = recipeService.create(validRequest(Set.of(DietType.VEGAN)));
        RecipeRequest update = new RecipeRequest(
                categoryId, "Updated peanut noodles", "Updated description", null, 8, 12,
                Difficulty.MEDIUM, 2, Set.of(DietType.VEGETARIAN),
                List.of(new RecipeIngredientRequest(peanutIngredientId, new BigDecimal("75"), "g")),
                List.of(new RecipeStepRequest(1, "Mix and cook")),
                new NutritionRequest(
                        new BigDecimal("500"), new BigDecimal("20"), new BigDecimal("15"),
                        new BigDecimal("70"), new BigDecimal("9"), new BigDecimal("5"),
                        new BigDecimal("400")));

        RecipeResponse updated = recipeService.update(created.recipeId(), update);

        assertThat(updated.title()).isEqualTo("Updated peanut noodles");
        assertThat(updated.ingredients()).singleElement().satisfies(
                ingredient -> assertThat(ingredient.quantity()).isEqualByComparingTo("75"));
        assertThat(updated.steps()).extracting("instruction").containsExactly("Mix and cook");
        assertThat(updated.nutrition().calories()).isEqualByComparingTo("500");
    }

    private RecipeRequest validRequest(Set<DietType> dietTypes) {
        return new RecipeRequest(
                categoryId, "Peanut noodles", "Quick noodles", null, 5, 10, Difficulty.EASY, 1,
                dietTypes,
                List.of(new RecipeIngredientRequest(peanutIngredientId, new BigDecimal("50"), "g")),
                List.of(
                        new RecipeStepRequest(1, "Boil noodles"),
                        new RecipeStepRequest(2, "Add peanut")),
                nutrition());
    }

    private NutritionRequest nutrition() {
        return new NutritionRequest(
                new BigDecimal("420"), new BigDecimal("15"), new BigDecimal("12"),
                new BigDecimal("60"), new BigDecimal("8"), new BigDecimal("4"),
                new BigDecimal("350"));
    }
}
