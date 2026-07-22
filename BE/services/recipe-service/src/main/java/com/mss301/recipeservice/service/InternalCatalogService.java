package com.mss301.recipeservice.service;

import com.mss301.recipeservice.dto.CatalogDtos.AllergenResponse;
import com.mss301.recipeservice.dto.CatalogDtos.CatalogSnapshotResponse;
import com.mss301.recipeservice.dto.CatalogDtos.RecipeBatchResponse;
import java.util.List;

public interface InternalCatalogService {

    CatalogSnapshotResponse getSnapshot();

    List<AllergenResponse> getAllergens();

    AllergenResponse getAllergen(Long allergenId);

    RecipeBatchResponse getBatch(List<Long> recipeIds);
}
