package com.mss301.recipeservice.service;

import com.mss301.recipeservice.dto.CatalogDtos.RecipeRequest;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeResponse;
import com.mss301.recipeservice.dto.RecipeSearchCriteria;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface RecipeManagementService {

    RecipeResponse create(RecipeRequest request);

    RecipeResponse get(Long recipeId);

    Page<RecipeResponse> search(RecipeSearchCriteria criteria, Pageable pageable);

    RecipeResponse update(Long recipeId, RecipeRequest request);

    void delete(Long recipeId);
}
