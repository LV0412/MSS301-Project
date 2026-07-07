package com.mss301.recipeservice;

import static org.assertj.core.api.Assertions.assertThat;

import com.mss301.recipeservice.config.RecipeDataInitializer;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.DefaultApplicationArguments;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(properties = {
        "app.seed-data.enabled=true",
        "spring.datasource.url=jdbc:h2:mem:recipe_seed_service;MODE=PostgreSQL;DB_CLOSE_DELAY=-1;DATABASE_TO_LOWER=TRUE"
})
@ActiveProfiles("test")
class RecipeDataInitializerIntegrationTest {

    @Autowired private RecipeDataInitializer recipeDataInitializer;
    @Autowired private JdbcTemplate jdbcTemplate;

    @Test
    void seedsEveryRecipeTableAndIsIdempotent() {
        Map<String, Integer> initialCounts = tableCounts();

        assertThat(initialCounts)
                .allSatisfy((tableName, rowCount) -> assertThat(rowCount)
                        .as("expected seeded rows in table %s", tableName)
                        .isGreaterThan(0));

        recipeDataInitializer.run(new DefaultApplicationArguments(new String[0]));

        assertThat(tableCounts()).isEqualTo(initialCounts);
    }

    private Map<String, Integer> tableCounts() {
        return Map.of(
                "categories", countRows("categories"),
                "allergens", countRows("allergens"),
                "ingredients", countRows("ingredients"),
                "ingredient_allergens", countRows("ingredient_allergens"),
                "recipes", countRows("recipes"),
                "recipe_diet_types", countRows("recipe_diet_types"),
                "recipe_ingredients", countRows("recipe_ingredients"),
                "recipe_steps", countRows("recipe_steps"),
                "nutrition_info", countRows("nutrition_info"));
    }

    private int countRows(String tableName) {
        Integer count = jdbcTemplate.queryForObject("select count(*) from " + tableName, Integer.class);
        return count == null ? 0 : count;
    }
}
