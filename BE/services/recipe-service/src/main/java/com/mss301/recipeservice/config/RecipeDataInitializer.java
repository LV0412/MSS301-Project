package com.mss301.recipeservice.config;

import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.CategoryRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.IngredientRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.NutritionRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeIngredientRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeStepRequest;
import com.mss301.recipeservice.application.AllergenService;
import com.mss301.recipeservice.application.CategoryService;
import com.mss301.recipeservice.application.IngredientService;
import com.mss301.recipeservice.application.RecipeManagementService;
import com.mss301.recipeservice.domain.Allergen;
import com.mss301.recipeservice.domain.Category;
import com.mss301.recipeservice.domain.DietType;
import com.mss301.recipeservice.domain.Difficulty;
import com.mss301.recipeservice.domain.Ingredient;
import com.mss301.recipeservice.infrastructure.repositories.AllergenRepository;
import com.mss301.recipeservice.infrastructure.repositories.CategoryRepository;
import com.mss301.recipeservice.infrastructure.repositories.IngredientRepository;
import com.mss301.recipeservice.infrastructure.repositories.RecipeRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
@Transactional
@ConditionalOnProperty(prefix = "app.seed-data", name = "enabled", havingValue = "true", matchIfMissing = true)
public class RecipeDataInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(RecipeDataInitializer.class);

    private final CategoryRepository categoryRepository;
    private final AllergenRepository allergenRepository;
    private final IngredientRepository ingredientRepository;
    private final RecipeRepository recipeRepository;
    private final CategoryService categoryService;
    private final AllergenService allergenService;
    private final IngredientService ingredientService;
    private final RecipeManagementService recipeManagementService;

    @Override
    public void run(ApplicationArguments args) {
        Long breakfastCategoryId = getOrCreateCategory(
                "Breakfast", "Balanced recipes to start the day with steady energy.");
        Long lunchCategoryId = getOrCreateCategory(
                "Lunch", "Satisfying midday meals for workdays and weekends.");
        Long dinnerCategoryId = getOrCreateCategory(
                "Dinner", "Hearty evening dishes with complete nutrition.");
        Long snackCategoryId = getOrCreateCategory(
                "Snack", "Quick bites and light treats between main meals.");

        Long peanutAllergenId = getOrCreateAllergen("Peanut");
        Long dairyAllergenId = getOrCreateAllergen("Dairy");
        Long glutenAllergenId = getOrCreateAllergen("Gluten");
        Long soyAllergenId = getOrCreateAllergen("Soy");
        Long treeNutAllergenId = getOrCreateAllergen("Tree Nut");
        Long eggAllergenId = getOrCreateAllergen("Egg");
        Long shellfishAllergenId = getOrCreateAllergen("Shellfish");

        Long rolledOatsId = getOrCreateIngredient("Rolled Oats", Set.of());
        Long almondMilkId = getOrCreateIngredient("Almond Milk", Set.of(treeNutAllergenId));
        Long chiaSeedsId = getOrCreateIngredient("Chia Seeds", Set.of());
        Long bananaId = getOrCreateIngredient("Banana", Set.of());
        Long blueberriesId = getOrCreateIngredient("Blueberries", Set.of());
        Long honeyId = getOrCreateIngredient("Honey", Set.of());
        Long chickenBreastId = getOrCreateIngredient("Chicken Breast", Set.of());
        Long brownRiceId = getOrCreateIngredient("Brown Rice", Set.of());
        Long broccoliId = getOrCreateIngredient("Broccoli", Set.of());
        Long garlicId = getOrCreateIngredient("Garlic", Set.of());
        Long soySauceId = getOrCreateIngredient("Soy Sauce", Set.of(soyAllergenId, glutenAllergenId));
        Long oliveOilId = getOrCreateIngredient("Olive Oil", Set.of());
        Long tofuId = getOrCreateIngredient("Tofu", Set.of(soyAllergenId));
        Long peanutButterId = getOrCreateIngredient("Peanut Butter", Set.of(peanutAllergenId));
        Long bellPepperId = getOrCreateIngredient("Bell Pepper", Set.of());
        Long greekYogurtId = getOrCreateIngredient("Greek Yogurt", Set.of(dairyAllergenId));
        Long mixedBerriesId = getOrCreateIngredient("Mixed Berries", Set.of());
        getOrCreateIngredient("Egg", Set.of(eggAllergenId));
        getOrCreateIngredient("Shrimp", Set.of(shellfishAllergenId));

        if (recipeRepository.count() > 0) {
            log.info("Recipe seed skipped because {} recipes already exist.", recipeRepository.count());
            return;
        }

        recipeManagementService.create(new RecipeRequest(
                breakfastCategoryId,
                "Berry Overnight Oats",
                "Creamy overnight oats with berries, chia seeds, and almond milk.",
                "https://images.example.com/recipes/berry-overnight-oats.jpg",
                10,
                0,
                Difficulty.EASY,
                2,
                Set.of(DietType.VEGETARIAN),
                List.of(
                        ingredient(rolledOatsId, "80", "g"),
                        ingredient(almondMilkId, "240", "ml"),
                        ingredient(chiaSeedsId, "15", "g"),
                        ingredient(bananaId, "1", "piece"),
                        ingredient(blueberriesId, "80", "g"),
                        ingredient(honeyId, "10", "g")),
                List.of(
                        step(1, "Combine the oats, almond milk, and chia seeds in a jar."),
                        step(2, "Stir in sliced banana and refrigerate overnight."),
                        step(3, "Top with blueberries and honey before serving.")),
                nutrition("365", "11", "9", "58", "10", "17", "95")));

        recipeManagementService.create(new RecipeRequest(
                lunchCategoryId,
                "Garlic Chicken Rice Bowl",
                "A simple chicken bowl with rice, broccoli, and a savory garlic soy finish.",
                "https://images.example.com/recipes/garlic-chicken-rice-bowl.jpg",
                15,
                20,
                Difficulty.MEDIUM,
                2,
                Set.of(DietType.NORMAL),
                List.of(
                        ingredient(chickenBreastId, "300", "g"),
                        ingredient(brownRiceId, "180", "g"),
                        ingredient(broccoliId, "200", "g"),
                        ingredient(garlicId, "12", "g"),
                        ingredient(soySauceId, "30", "ml"),
                        ingredient(oliveOilId, "15", "ml")),
                List.of(
                        step(1, "Cook the brown rice according to package directions."),
                        step(2, "Saute the garlic in olive oil, then add the chicken and cook through."),
                        step(3, "Add broccoli and soy sauce, then cook until the broccoli is tender."),
                        step(4, "Serve the chicken mixture over the rice.")),
                nutrition("540", "42", "15", "55", "6", "5", "620")));

        recipeManagementService.create(new RecipeRequest(
                dinnerCategoryId,
                "Peanut Tofu Stir-Fry",
                "Colorful tofu stir-fry with peanut sauce for a quick weeknight dinner.",
                "https://images.example.com/recipes/peanut-tofu-stir-fry.jpg",
                15,
                15,
                Difficulty.MEDIUM,
                2,
                Set.of(DietType.VEGAN, DietType.LOW_CARB),
                List.of(
                        ingredient(tofuId, "280", "g"),
                        ingredient(peanutButterId, "32", "g"),
                        ingredient(broccoliId, "180", "g"),
                        ingredient(bellPepperId, "150", "g"),
                        ingredient(soySauceId, "25", "ml"),
                        ingredient(garlicId, "10", "g"),
                        ingredient(oliveOilId, "10", "ml")),
                List.of(
                        step(1, "Whisk peanut butter, soy sauce, and a splash of water into a smooth sauce."),
                        step(2, "Sear tofu in olive oil until golden on the edges."),
                        step(3, "Stir-fry the broccoli, bell pepper, and garlic until crisp-tender."),
                        step(4, "Return tofu to the pan, pour in the sauce, and toss to coat.")),
                nutrition("410", "24", "24", "23", "7", "8", "540")));

        recipeManagementService.create(new RecipeRequest(
                snackCategoryId,
                "Greek Yogurt Parfait",
                "Layered yogurt parfait with berries, chia seeds, and a drizzle of honey.",
                "https://images.example.com/recipes/greek-yogurt-parfait.jpg",
                10,
                0,
                Difficulty.EASY,
                1,
                Set.of(DietType.VEGETARIAN),
                List.of(
                        ingredient(greekYogurtId, "200", "g"),
                        ingredient(mixedBerriesId, "90", "g"),
                        ingredient(chiaSeedsId, "12", "g"),
                        ingredient(honeyId, "8", "g")),
                List.of(
                        step(1, "Layer half of the yogurt and berries into a glass."),
                        step(2, "Add the remaining yogurt, then top with berries and chia seeds."),
                        step(3, "Finish with honey just before serving.")),
                nutrition("255", "18", "7", "28", "6", "18", "72")));

        log.info("Recipe seed completed with {} recipes.", recipeRepository.count());
    }

    private Long getOrCreateCategory(String name, String description) {
        return categoryRepository.findByNameIgnoreCase(name)
                .map(Category::getCategoryId)
                .orElseGet(() -> categoryService.create(new CategoryRequest(name, description)).categoryId());
    }

    private Long getOrCreateAllergen(String name) {
        return allergenRepository.findByNameIgnoreCase(name)
                .map(Allergen::getAllergenId)
                .orElseGet(() -> allergenService.create(new AllergenRequest(name)).allergenId());
    }

    private Long getOrCreateIngredient(String name, Set<Long> allergenIds) {
        return ingredientRepository.findByNameIgnoreCase(name)
                .map(Ingredient::getIngredientId)
                .orElseGet(() -> ingredientService.create(new IngredientRequest(name, allergenIds)).ingredientId());
    }

    private RecipeIngredientRequest ingredient(Long ingredientId, String quantity, String unit) {
        return new RecipeIngredientRequest(ingredientId, new BigDecimal(quantity), unit);
    }

    private RecipeStepRequest step(int order, String instruction) {
        return new RecipeStepRequest(order, instruction);
    }

    private NutritionRequest nutrition(
            String calories,
            String protein,
            String fat,
            String carbs,
            String fiber,
            String sugar,
            String sodium) {
        return new NutritionRequest(
                new BigDecimal(calories),
                new BigDecimal(protein),
                new BigDecimal(fat),
                new BigDecimal(carbs),
                new BigDecimal(fiber),
                new BigDecimal(sugar),
                new BigDecimal(sodium));
    }
}
