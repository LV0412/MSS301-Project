package com.mss301.recipeservice.service.impl;

import com.mss301.recipeservice.dto.CatalogDtos.IngredientRequest;
import com.mss301.recipeservice.dto.CatalogDtos.IngredientResponse;
import com.mss301.recipeservice.entity.Allergen;
import com.mss301.recipeservice.entity.Ingredient;
import com.mss301.recipeservice.exception.DuplicateResourceException;
import com.mss301.recipeservice.exception.ResourceInUseException;
import com.mss301.recipeservice.exception.ResourceNotFoundException;
import com.mss301.recipeservice.mapper.RecipeMapper;
import com.mss301.recipeservice.repository.AllergenRepository;
import com.mss301.recipeservice.repository.IngredientRepository;
import com.mss301.recipeservice.repository.RecipeIngredientRepository;
import com.mss301.recipeservice.service.IngredientService;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class IngredientServiceImpl implements IngredientService {

    private final IngredientRepository ingredientRepository;
    private final AllergenRepository allergenRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;
    private final RecipeMapper mapper;

    public IngredientResponse create(IngredientRequest request) {
        String name = request.name().trim();
        ensureNameAvailable(name, null);
        Ingredient ingredient = Ingredient.builder().name(name).allergens(loadAllergens(request.allergenIds())).build();
        return mapper.toResponse(ingredientRepository.save(ingredient));
    }

    @Transactional(readOnly = true)
    public IngredientResponse get(Long id) {
        return mapper.toResponse(find(id));
    }

    @Transactional(readOnly = true)
    public Page<IngredientResponse> list(String query, Pageable pageable) {
        Page<Ingredient> page = query == null || query.isBlank()
                ? ingredientRepository.findAll(pageable)
                : ingredientRepository.findByNameContainingIgnoreCase(query.trim(), pageable);
        return page.map(mapper::toResponse);
    }

    public IngredientResponse update(Long id, IngredientRequest request) {
        Ingredient ingredient = find(id);
        String name = request.name().trim();
        ensureNameAvailable(name, id);
        ingredient.setName(name);
        ingredient.setAllergens(loadAllergens(request.allergenIds()));
        return mapper.toResponse(ingredientRepository.save(ingredient));
    }

    public void delete(Long id) {
        Ingredient ingredient = find(id);
        if (recipeIngredientRepository.existsByIngredientIngredientId(id)) {
            throw new ResourceInUseException("Ingredient", id);
        }
        ingredientRepository.delete(ingredient);
    }

    Ingredient find(Long id) {
        return ingredientRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Ingredient", id));
    }

    private Set<Allergen> loadAllergens(Set<Long> ids) {
        if (ids == null || ids.isEmpty()) return new LinkedHashSet<>();
        List<Allergen> allergens = allergenRepository.findAllById(ids);
        if (allergens.size() != ids.size()) {
            Long missing = ids.stream().filter(id -> allergens.stream().noneMatch(a -> a.getAllergenId().equals(id)))
                    .findFirst().orElse(null);
            throw new ResourceNotFoundException("Allergen", missing);
        }
        return new LinkedHashSet<>(allergens);
    }

    private void ensureNameAvailable(String name, Long currentId) {
        ingredientRepository.findByNameIgnoreCase(name)
                .filter(existing -> !existing.getIngredientId().equals(currentId))
                .ifPresent(existing -> { throw new DuplicateResourceException("Ingredient", name); });
    }
}
