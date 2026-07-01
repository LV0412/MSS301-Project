package com.mss301.recipeservice.api;

import com.mss301.recipeservice.api.dto.CatalogDtos.IngredientRequest;
import com.mss301.recipeservice.api.dto.CatalogDtos.IngredientResponse;
import com.mss301.recipeservice.application.IngredientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/api/ingredients", "/api/v1/ingredients"})
@RequiredArgsConstructor
public class IngredientController {

    private final IngredientService ingredientService;

    @PostMapping
    public ResponseEntity<IngredientResponse> create(@Valid @RequestBody IngredientRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ingredientService.create(request));
    }

    @GetMapping("/{id}")
    public IngredientResponse get(@PathVariable Long id) {
        return ingredientService.get(id);
    }

    @GetMapping
    public Page<IngredientResponse> list(
            @RequestParam(required = false) String query,
            @PageableDefault(size = 20, sort = "name") Pageable pageable) {
        return ingredientService.list(query, pageable);
    }

    @PutMapping("/{id}")
    public IngredientResponse update(@PathVariable Long id, @Valid @RequestBody IngredientRequest request) {
        return ingredientService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        ingredientService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
