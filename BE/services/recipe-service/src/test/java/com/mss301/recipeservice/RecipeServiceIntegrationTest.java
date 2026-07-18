package com.mss301.recipeservice;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

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
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class RecipeServiceIntegrationTest {

    @Autowired private CategoryService categoryService;
    @Autowired private AllergenService allergenService;
    @Autowired private IngredientService ingredientService;
    @Autowired private RecipeManagementService recipeService;
    @Autowired private MockMvc mockMvc;

    private Long categoryId;
    private Long peanutAllergenId;
    private Long peanutIngredientId;
    private Long riceIngredientId;

    @BeforeEach
    void setUpCatalog() {
        categoryId = categoryService.create(new CategoryRequest("Lunch", "Main meals")).categoryId();
        peanutAllergenId = allergenService.create(new AllergenRequest("Peanut")).allergenId();
        peanutIngredientId = ingredientService.create(
                new IngredientRequest("Peanut", Set.of(peanutAllergenId))).ingredientId();
        riceIngredientId = ingredientService.create(new IngredientRequest("Rice", Set.of())).ingredientId();
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
    void filtersByDietAndExcludedAllergensTogether() {
        recipeService.create(validRequest(Set.of(DietType.VEGAN), peanutIngredientId, "Peanut noodles"));
        recipeService.create(validRequest(Set.of(DietType.VEGAN), riceIngredientId, "Rice bowl"));
        recipeService.create(validRequest(Set.of(DietType.NORMAL), riceIngredientId, "Plain rice"));

        var results = recipeService.search(new RecipeSearchCriteria(
                null, null, null, null, null, null, DietType.VEGAN, Set.of(peanutAllergenId)),
                PageRequest.of(0, 10));

        assertThat(results).hasSize(1);
        assertThat(results.getContent().getFirst().title()).isEqualTo("Rice bowl");
    }

    @Test
    void rejectsRecipeWithoutIngredients() {
        RecipeRequest invalid = new RecipeRequest(
                categoryId, "Rice bowl", "Simple rice bowl", null, 5, 10, Difficulty.EASY, 1,
                Set.of(DietType.VEGAN),
                List.of(),
                List.of(new RecipeStepRequest(1, "Cook rice")),
                nutrition());

        assertThatThrownBy(() -> recipeService.create(invalid))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("at least one ingredient");
    }

    @Test
    void rejectsRecipeWithoutSteps() {
        RecipeRequest invalid = new RecipeRequest(
                categoryId, "Rice bowl", "Simple rice bowl", null, 5, 10, Difficulty.EASY, 1,
                Set.of(DietType.VEGAN),
                List.of(new RecipeIngredientRequest(riceIngredientId, new BigDecimal("100"), "g")),
                List.of(),
                nutrition());

        assertThatThrownBy(() -> recipeService.create(invalid))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("at least one step");
    }

    @Test
    void rejectsRecipeWithoutNutrition() {
        RecipeRequest invalid = new RecipeRequest(
                categoryId, "Rice bowl", "Simple rice bowl", null, 5, 10, Difficulty.EASY, 1,
                Set.of(DietType.VEGAN),
                List.of(new RecipeIngredientRequest(riceIngredientId, new BigDecimal("100"), "g")),
                List.of(new RecipeStepRequest(1, "Cook rice")),
                null);

        assertThatThrownBy(() -> recipeService.create(invalid))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("nutrition");
    }

    @Test
    void rejectsDuplicateIngredientsInRecipe() {
        RecipeRequest invalid = new RecipeRequest(
                categoryId, "Double rice bowl", "Rice listed twice", null, 5, 10, Difficulty.EASY, 1,
                Set.of(DietType.VEGAN),
                List.of(
                        new RecipeIngredientRequest(riceIngredientId, new BigDecimal("100"), "g"),
                        new RecipeIngredientRequest(riceIngredientId, new BigDecimal("50"), "g")),
                List.of(new RecipeStepRequest(1, "Cook rice")),
                nutrition());

        assertThatThrownBy(() -> recipeService.create(invalid))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessageContaining("same ingredient");
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
                        new BigDecimal("260"), new BigDecimal("500"), new BigDecimal("20"),
                        new BigDecimal("15"), new BigDecimal("4"), new BigDecimal("0.1"),
                        new BigDecimal("15"), new BigDecimal("70"), new BigDecimal("9"),
                        new BigDecimal("5"), new BigDecimal("400"), new BigDecimal("620"),
                        new BigDecimal("180"), new BigDecimal("2.8"), new BigDecimal("4.6"),
                        new BigDecimal("18"), new BigDecimal("0.4"), new BigDecimal("0.2"),
                        new BigDecimal("7.5"), new BigDecimal("0.5"), new BigDecimal("80"),
                        new BigDecimal("0.1"), new BigDecimal("12"), new BigDecimal("70"),
                        new BigDecimal("3.5")));

        RecipeResponse updated = recipeService.update(created.recipeId(), update);

        assertThat(updated.title()).isEqualTo("Updated peanut noodles");
        assertThat(updated.ingredients()).singleElement().satisfies(
                ingredient -> assertThat(ingredient.quantity()).isEqualByComparingTo("75"));
        assertThat(updated.steps()).extracting("instruction").containsExactly("Mix and cook");
        assertThat(updated.nutrition().calories()).isEqualByComparingTo("500");
    }

    @Test
    void exposesSnapshotApiForAiRecommendation() throws Exception {
        RecipeResponse created = recipeService.create(validRequest(Set.of(DietType.VEGAN)));

        mockMvc.perform(get("/api/internal/recipes/snapshot"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.summary.totalRecipes").value(1))
                .andExpect(jsonPath("$.summary.totalCategories").value(1))
                .andExpect(jsonPath("$.summary.totalIngredients").value(2))
                .andExpect(jsonPath("$.summary.totalAllergens").value(1))
                .andExpect(jsonPath("$.recipes[0].recipeId").value(created.recipeId()))
                .andExpect(jsonPath("$.recipes[0].title").value("Peanut noodles"))
                .andExpect(jsonPath("$.recipes[0].nutrition.vitaminB12").value(0.2))
                .andExpect(jsonPath("$.ingredients[0].name").value("Peanut"));
    }

    @Test
    void exposesBatchApiWithMissingIdsForAiSync() throws Exception {
        RecipeResponse created = recipeService.create(validRequest(Set.of(DietType.VEGAN)));

        mockMvc.perform(get("/api/internal/recipes/batch")
                        .param("ids", created.recipeId().toString(), "999999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requestedIds[0]").value(created.recipeId()))
                .andExpect(jsonPath("$.requestedIds[1]").value(999999))
                .andExpect(jsonPath("$.missingIds[0]").value(999999))
                .andExpect(jsonPath("$.recipes.length()").value(1))
                .andExpect(jsonPath("$.recipes[0].recipeId").value(created.recipeId()));
    }

    private RecipeRequest validRequest(Set<DietType> dietTypes) {
        return validRequest(dietTypes, peanutIngredientId, "Peanut noodles");
    }

    private RecipeRequest validRequest(Set<DietType> dietTypes, Long ingredientId, String title) {
        return new RecipeRequest(
                categoryId, title, "Quick noodles", null, 5, 10, Difficulty.EASY, 1,
                dietTypes,
                List.of(new RecipeIngredientRequest(ingredientId, new BigDecimal("50"), "g")),
                List.of(
                        new RecipeStepRequest(1, "Boil noodles"),
                        new RecipeStepRequest(2, "Add peanut")),
                nutrition());
    }

    private NutritionRequest nutrition() {
        return new NutritionRequest(
                new BigDecimal("240"), new BigDecimal("420"), new BigDecimal("15"),
                new BigDecimal("12"), new BigDecimal("3.5"), new BigDecimal("0.1"),
                new BigDecimal("12"), new BigDecimal("60"), new BigDecimal("8"),
                new BigDecimal("4"), new BigDecimal("350"), new BigDecimal("540"),
                new BigDecimal("150"), new BigDecimal("1.4"), new BigDecimal("2.1"),
                new BigDecimal("22"), new BigDecimal("0.2"), new BigDecimal("0.1"),
                new BigDecimal("5.4"), new BigDecimal("0.3"), new BigDecimal("48"),
                new BigDecimal("0.2"), new BigDecimal("10"), new BigDecimal("80"),
                new BigDecimal("2.5"));
    }
}
