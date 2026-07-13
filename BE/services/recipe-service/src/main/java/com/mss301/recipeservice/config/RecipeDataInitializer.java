package com.mss301.recipeservice.config;

import com.mss301.recipeservice.infrastructure.repositories.RecipeRepository;
import java.nio.charset.StandardCharsets;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "app.seed-data", name = "enabled", havingValue = "true", matchIfMissing = true)
public class RecipeDataInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(RecipeDataInitializer.class);
    private static final String CLEANUP_SCRIPT_PATH = "seed/recipe-data-cleanup.sql";
    private static final String SEED_SCRIPT_PATH = "seed/recipe-data.sql";

    private final RecipeRepository recipeRepository;
    private final DataSource dataSource;

    @Override
    public void run(ApplicationArguments args) {
        long existingRecipeCount = recipeRepository.count();
        if (existingRecipeCount > 0) {
            log.info("Replacing {} existing recipes with the configured seed dataset.", existingRecipeCount);
        }

        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.setSqlScriptEncoding(StandardCharsets.UTF_8.name());
        populator.addScript(new ClassPathResource(CLEANUP_SCRIPT_PATH));
        populator.addScript(new ClassPathResource(SEED_SCRIPT_PATH));
        populator.execute(dataSource);

        log.info("Recipe seed refreshed with {} recipes.", recipeRepository.count());
    }
}
