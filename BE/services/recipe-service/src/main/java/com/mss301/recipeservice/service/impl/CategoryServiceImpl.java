package com.mss301.recipeservice.service.impl;

import com.mss301.recipeservice.dto.CatalogDtos.CategoryRequest;
import com.mss301.recipeservice.dto.CatalogDtos.CategoryResponse;
import com.mss301.recipeservice.entity.Category;
import com.mss301.recipeservice.exception.DuplicateResourceException;
import com.mss301.recipeservice.exception.ResourceInUseException;
import com.mss301.recipeservice.exception.ResourceNotFoundException;
import com.mss301.recipeservice.mapper.RecipeMapper;
import com.mss301.recipeservice.repository.CategoryRepository;
import com.mss301.recipeservice.repository.RecipeRepository;
import com.mss301.recipeservice.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final RecipeRepository recipeRepository;
    private final RecipeMapper mapper;

    public CategoryResponse create(CategoryRequest request) {
        String name = request.name().trim();
        ensureNameAvailable(name, null);
        return mapper.toResponse(categoryRepository.save(Category.builder()
                .name(name).description(trimToNull(request.description())).build()));
    }

    @Transactional(readOnly = true)
    public CategoryResponse get(Long id) {
        return mapper.toResponse(find(id));
    }

    @Transactional(readOnly = true)
    public Page<CategoryResponse> list(Pageable pageable) {
        return categoryRepository.findAll(pageable).map(mapper::toResponse);
    }

    public CategoryResponse update(Long id, CategoryRequest request) {
        Category category = find(id);
        String name = request.name().trim();
        ensureNameAvailable(name, id);
        category.setName(name);
        category.setDescription(trimToNull(request.description()));
        return mapper.toResponse(categoryRepository.save(category));
    }

    public void delete(Long id) {
        Category category = find(id);
        if (recipeRepository.existsByCategoryCategoryId(id)) {
            throw new ResourceInUseException("Category", id);
        }
        categoryRepository.delete(category);
    }

    Category find(Long id) {
        return categoryRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Category", id));
    }

    private void ensureNameAvailable(String name, Long currentId) {
        categoryRepository.findByNameIgnoreCase(name)
                .filter(existing -> !existing.getCategoryId().equals(currentId))
                .ifPresent(existing -> { throw new DuplicateResourceException("Category", name); });
    }

    private String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
