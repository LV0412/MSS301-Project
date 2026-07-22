package com.mss301.recipeservice.service;

import com.mss301.recipeservice.dto.CatalogDtos.CategoryRequest;
import com.mss301.recipeservice.dto.CatalogDtos.CategoryResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface CategoryService {

    CategoryResponse create(CategoryRequest request);

    CategoryResponse get(Long id);

    Page<CategoryResponse> list(Pageable pageable);

    CategoryResponse update(Long id, CategoryRequest request);

    void delete(Long id);
}
