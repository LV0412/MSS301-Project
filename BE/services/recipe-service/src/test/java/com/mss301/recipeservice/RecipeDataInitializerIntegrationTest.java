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
    void reseedsEveryRecipeTableAndRestoresCanonicalData() {
        Map<String, Integer> initialCounts = tableCounts();

        assertThat(initialCounts)
                .containsExactlyInAnyOrderEntriesOf(Map.of(
                        "categories", 10,
                        "allergens", 9,
                        "ingredients", 100,
                        "ingredient_allergens", 79,
                        "recipes", 50,
                        "recipe_diet_types", 50,
                        "recipe_ingredients", 228,
                        "recipe_steps", 232,
                        "nutrition_info", 50));
        assertThat(jdbcTemplate.queryForObject(
                        "select title from recipes where recipe_id = 1", String.class))
                .isEqualTo("Cháo yến mạch chuối sữa");

        jdbcTemplate.update("update recipes set title = ? where recipe_id = 1", "legacy title");

        recipeDataInitializer.run(new DefaultApplicationArguments(new String[0]));

        assertThat(tableCounts()).isEqualTo(initialCounts);
        assertThat(jdbcTemplate.queryForObject(
                        "select title from recipes where recipe_id = 1", String.class))
                .isEqualTo("Cháo yến mạch chuối sữa");
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
