package com.mss301.recipeservice.controller;

import com.mss301.recipeservice.dto.CatalogDtos.AllergenRequest;
import com.mss301.recipeservice.dto.CatalogDtos.AllergenResponse;
import com.mss301.recipeservice.service.AllergenService;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping({"/api/allergens", "/api/v1/allergens"})
@RequiredArgsConstructor
public class AllergenController {

    private final AllergenService allergenService;

    @PostMapping
    public ResponseEntity<AllergenResponse> create(@Valid @RequestBody AllergenRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(allergenService.create(request));
    }

    @GetMapping("/{id}")
    public AllergenResponse get(@PathVariable Long id) {
        return allergenService.get(id);
    }

    @GetMapping
    public Page<AllergenResponse> list(@PageableDefault(size = 20, sort = "name") Pageable pageable) {
        return allergenService.list(pageable);
    }

    @PutMapping("/{id}")
    public AllergenResponse update(@PathVariable Long id, @Valid @RequestBody AllergenRequest request) {
        return allergenService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        allergenService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
