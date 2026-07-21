package com.mss301.userservice.config;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.recipe-service")
public record RecipeServiceProperties(
        String baseUrl,
        Duration recipeCacheTtl,
        Duration allergenCacheTtl) {

    public RecipeServiceProperties {
        if (baseUrl == null || baseUrl.isBlank()) {
            baseUrl = "http://localhost:8002";
        }
        if (recipeCacheTtl == null) {
            recipeCacheTtl = Duration.ofMinutes(10);
        }
        if (allergenCacheTtl == null) {
            allergenCacheTtl = Duration.ofHours(12);
        }
    }
}
