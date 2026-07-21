package com.mss301.recipeservice.api;

import com.mss301.recipeservice.api.dto.CatalogDtos.AllergenResponse;
import com.mss301.recipeservice.application.InternalCatalogService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/internal/allergens")
@RequiredArgsConstructor
public class InternalAllergenController {

    private final InternalCatalogService internalCatalogService;

    @GetMapping
    public List<AllergenResponse> list() {
        return internalCatalogService.getAllergens();
    }

    @GetMapping("/{allergenId}")
    public AllergenResponse get(@PathVariable Long allergenId) {
        return internalCatalogService.getAllergen(allergenId);
    }
}
