package com.mss301.recipeservice.controller;

import com.mss301.recipeservice.dto.CatalogDtos.RecipeRequest;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.dto.RecipeSearchCriteria;
import com.mss301.recipeservice.service.RecipeManagementService;
import com.mss301.recipeservice.entity.DietType;
import jakarta.validation.Valid;
import java.math.BigDecimal;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/api/recipes", "/api/v1/recipes"})
@RequiredArgsConstructor
public class RecipeController {

    private final RecipeManagementService recipeService;

    @PostMapping
    public ResponseEntity<RecipeResponse> create(@Valid @RequestBody RecipeRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(recipeService.create(request));
    }

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
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return recipeService.search(new RecipeSearchCriteria(
                query, categoryId, ingredientIds, ingredient, minCalories, maxCalories,
                dietType, excludedAllergenIds), pageable);
    }

    @PutMapping("/{recipeId}")
    public RecipeResponse update(
            @PathVariable Long recipeId,
            @Valid @RequestBody RecipeRequest request) {
        return recipeService.update(recipeId, request);
    }

    @DeleteMapping("/{recipeId}")
    public ResponseEntity<Void> delete(@PathVariable Long recipeId) {
        recipeService.delete(recipeId);
        return ResponseEntity.noContent().build();
    }
}
