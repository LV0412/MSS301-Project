package com.mss301.recipeservice.application;

import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.CatalogSnapshotResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.CatalogSnapshotSummaryResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.CategoryResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.IngredientResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeBatchResponse;
import com.mss301.recipeservice.api.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.exception.ResourceNotFoundException;
import com.mss301.recipeservice.infrastructure.repositories.AllergenRepository;
import com.mss301.recipeservice.infrastructure.repositories.CategoryRepository;
import com.mss301.recipeservice.infrastructure.repositories.IngredientRepository;
import com.mss301.recipeservice.infrastructure.repositories.RecipeRepository;
import java.time.LocalDateTime;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InternalCatalogService {

    private static final Sort CATEGORY_SORT = Sort.by(Sort.Direction.ASC, "name");
    private static final Sort ALLERGEN_SORT = Sort.by(Sort.Direction.ASC, "name");
    private static final Sort INGREDIENT_SORT = Sort.by(Sort.Direction.ASC, "name");
    private static final Sort RECIPE_SORT = Sort.by(Sort.Direction.DESC, "createdAt");

    private final RecipeRepository recipeRepository;
    private final CategoryRepository categoryRepository;
    private final IngredientRepository ingredientRepository;
    private final AllergenRepository allergenRepository;
    private final RecipeMapper mapper;

    public CatalogSnapshotResponse getSnapshot() {
        List<CategoryResponse> categories = categoryRepository.findAll(CATEGORY_SORT).stream()
                .map(mapper::toResponse)
                .toList();
        List<AllergenResponse> allergens = allergenRepository.findAll(ALLERGEN_SORT).stream()
                .map(mapper::toResponse)
                .toList();
        List<IngredientResponse> ingredients = ingredientRepository.findAll(INGREDIENT_SORT).stream()
                .map(mapper::toResponse)
                .toList();
        List<RecipeResponse> recipes = recipeRepository.findAll(RECIPE_SORT).stream()
                .map(mapper::toResponse)
                .toList();

        CatalogSnapshotSummaryResponse summary = new CatalogSnapshotSummaryResponse(
                recipes.size(),
                categories.size(),
                ingredients.size(),
                allergens.size());

        return new CatalogSnapshotResponse(
                LocalDateTime.now(),
                summary,
                categories,
                allergens,
                ingredients,
                recipes);
    }

    public List<AllergenResponse> getAllergens() {
        return allergenRepository.findAll(ALLERGEN_SORT).stream()
                .map(mapper::toResponse)
                .toList();
    }

    public AllergenResponse getAllergen(Long allergenId) {
        return allergenRepository.findById(allergenId)
                .map(mapper::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Allergen", allergenId));
    }

    public RecipeBatchResponse getBatch(List<Long> recipeIds) {
        List<Long> requestedIds = recipeIds == null
                ? List.of()
                : recipeIds.stream()
                        .filter(Objects::nonNull)
                        .collect(Collectors.collectingAndThen(
                                Collectors.toCollection(LinkedHashSet::new), List::copyOf));

        if (requestedIds.isEmpty()) {
            return new RecipeBatchResponse(List.of(), List.of(), List.of());
        }

        Set<Long> uniqueIds = new LinkedHashSet<>(requestedIds);
        Map<Long, RecipeResponse> recipesById = recipeRepository.findByRecipeIdIn(uniqueIds).stream()
                .map(mapper::toResponse)
                .collect(Collectors.toMap(
                        RecipeResponse::recipeId,
                        recipe -> recipe));

        List<RecipeResponse> recipes = requestedIds.stream()
                .map(recipesById::get)
                .filter(Objects::nonNull)
                .toList();

        List<Long> missingIds = requestedIds.stream()
                .filter(id -> !recipesById.containsKey(id))
                .toList();

        return new RecipeBatchResponse(requestedIds, missingIds, recipes);
    }
}
