package com.mss301.recipeservice.api;

import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.api.dto.RecipeSearchCriteria;
import com.mss301.recipeservice.application.RecipeManagementService;
import com.mss301.recipeservice.domain.DietType;
import java.math.BigDecimal;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/internal/recipes")
@RequiredArgsConstructor
public class InternalRecipeController {

    private final RecipeManagementService recipeService;

    @GetMapping("/{recipeId}")
    public RecipeResponse get(@PathVariable Long recipeId) {
        return recipeService.get(recipeId);
    }

    @GetMapping
    public Page<RecipeResponse> search(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Set<Long> ingredientIds,
            @RequestParam(required = false) String ingredient,
            @RequestParam(required = false) BigDecimal minCalories,
            @RequestParam(required = false) BigDecimal maxCalories,
            @RequestParam(required = false) DietType dietType,
            @RequestParam(required = false) Set<Long> excludedAllergenIds,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return recipeService.search(new RecipeSearchCriteria(
                query, categoryId, ingredientIds, ingredient, minCalories, maxCalories,
                dietType, excludedAllergenIds), pageable);
    }
}
