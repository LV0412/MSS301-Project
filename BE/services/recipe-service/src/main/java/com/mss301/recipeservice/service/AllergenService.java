package com.mss301.recipeservice.service;

import com.mss301.recipeservice.dto.CatalogDtos.AllergenRequest;
import com.mss301.recipeservice.dto.CatalogDtos.AllergenResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface AllergenService {

    AllergenResponse create(AllergenRequest request);

    AllergenResponse get(Long id);

    Page<AllergenResponse> list(Pageable pageable);

    AllergenResponse update(Long id, AllergenRequest request);

    void delete(Long id);
}
