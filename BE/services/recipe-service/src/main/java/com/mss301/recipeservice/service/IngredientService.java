package com.mss301.recipeservice.service;

import com.mss301.recipeservice.dto.CatalogDtos.IngredientRequest;
import com.mss301.recipeservice.dto.CatalogDtos.IngredientResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface IngredientService {

    IngredientResponse create(IngredientRequest request);

    IngredientResponse get(Long id);

    Page<IngredientResponse> list(String query, Pageable pageable);

    IngredientResponse update(Long id, IngredientRequest request);

    void delete(Long id);
}
