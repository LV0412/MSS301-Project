package com.mss301.recipeservice.application;

import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenResponse;
import com.mss301.recipeservice.domain.Allergen;
import com.mss301.recipeservice.exception.DuplicateResourceException;
import com.mss301.recipeservice.exception.ResourceInUseException;
import com.mss301.recipeservice.exception.ResourceNotFoundException;
import com.mss301.recipeservice.infrastructure.repositories.AllergenRepository;
import com.mss301.recipeservice.infrastructure.repositories.IngredientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AllergenService {

    private final AllergenRepository allergenRepository;
    private final IngredientRepository ingredientRepository;
    private final RecipeMapper mapper;

    public AllergenResponse create(AllergenRequest request) {
        String name = request.name().trim();
        ensureNameAvailable(name, null);
        return mapper.toResponse(allergenRepository.save(Allergen.builder().name(name).build()));
    }

    @Transactional(readOnly = true)
    public AllergenResponse get(Long id) {
        return mapper.toResponse(find(id));
    }

    @Transactional(readOnly = true)
    public Page<AllergenResponse> list(Pageable pageable) {
        return allergenRepository.findAll(pageable).map(mapper::toResponse);
    }

    public AllergenResponse update(Long id, AllergenRequest request) {
        Allergen allergen = find(id);
        String name = request.name().trim();
        ensureNameAvailable(name, id);
        allergen.setName(name);
        return mapper.toResponse(allergenRepository.save(allergen));
    }

    public void delete(Long id) {
        Allergen allergen = find(id);
        if (ingredientRepository.existsByAllergensAllergenId(id)) {
            throw new ResourceInUseException("Allergen", id);
        }
        allergenRepository.delete(allergen);
    }

    Allergen find(Long id) {
        return allergenRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Allergen", id));
    }

    private void ensureNameAvailable(String name, Long currentId) {
        allergenRepository.findByNameIgnoreCase(name)
                .filter(existing -> !existing.getAllergenId().equals(currentId))
                .ifPresent(existing -> { throw new DuplicateResourceException("Allergen", name); });
    }
}
