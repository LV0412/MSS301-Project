package com.mss301.userservice.client;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.mss301.userservice.config.RecipeServiceProperties;
import com.mss301.userservice.exception.InvalidAllergenReferenceException;
import com.mss301.userservice.exception.InvalidRecipeReferenceException;
import com.mss301.userservice.exception.RecipeCatalogUnavailableException;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

@Service
public class RecipeCatalogReferenceValidator {

    private static final String ALLERGEN_CACHE_KEY = "allergens";

    private final RestClient recipeServiceRestClient;
    private final Cache<Long, Boolean> recipeExistsCache;
    private final Cache<String, Set<Long>> allergenIdsCache;

    public RecipeCatalogReferenceValidator(
            @Qualifier("recipeServiceRestClient") RestClient recipeServiceRestClient,
            RecipeServiceProperties properties) {
        this.recipeServiceRestClient = recipeServiceRestClient;
        this.recipeExistsCache = Caffeine.newBuilder()
                .expireAfterWrite(properties.recipeCacheTtl())
                .maximumSize(10_000)
                .build();
        this.allergenIdsCache = Caffeine.newBuilder()
                .expireAfterWrite(properties.allergenCacheTtl())
                .maximumSize(1)
                .build();
    }

    public void requireRecipeExists(Long recipeId) {
        if (Boolean.TRUE.equals(recipeExistsCache.getIfPresent(recipeId))) {
            return;
        }

        try {
            recipeServiceRestClient.get()
                    .uri("/api/internal/recipes/{recipeId}", recipeId)
                    .retrieve()
                    .toBodilessEntity();
            recipeExistsCache.put(recipeId, true);
        } catch (RestClientResponseException exception) {
            if (exception.getStatusCode().isSameCodeAs(HttpStatus.NOT_FOUND)) {
                throw new InvalidRecipeReferenceException(recipeId);
            }
            throw new RecipeCatalogUnavailableException("Recipe Service returned "
                    + exception.getStatusCode().value() + " while validating recipe id " + recipeId);
        } catch (RestClientException exception) {
            throw new RecipeCatalogUnavailableException(
                    "Recipe Service is unavailable while validating recipe id " + recipeId);
        }
    }

    public void requireAllergenExists(Long allergenId) {
        Set<Long> allergenIds = allergenIdsCache.get(ALLERGEN_CACHE_KEY, key -> loadAllergenIds());
        if (!allergenIds.contains(allergenId)) {
            throw new InvalidAllergenReferenceException(allergenId);
        }
    }

    private Set<Long> loadAllergenIds() {
        try {
            AllergenReferenceResponse[] allergens = recipeServiceRestClient.get()
                    .uri("/api/internal/allergens")
                    .retrieve()
                    .body(AllergenReferenceResponse[].class);

            if (allergens == null) {
                return Set.of();
            }

            return Arrays.stream(allergens)
                    .map(AllergenReferenceResponse::allergenId)
                    .collect(Collectors.toUnmodifiableSet());
        } catch (RestClientException exception) {
            throw new RecipeCatalogUnavailableException("Recipe Service is unavailable while loading allergens");
        }
    }

    private record AllergenReferenceResponse(Long allergenId, String name) {
    }
}
