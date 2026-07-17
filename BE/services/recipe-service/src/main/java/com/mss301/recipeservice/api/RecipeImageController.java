package com.mss301.recipeservice.api;

import com.mss301.recipeservice.application.RecipeImageStorageService;
import com.mss301.recipeservice.application.RecipeImageStorageService.RecipeImageUploadResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping({"/api/recipes/upload-image", "/api/v1/recipes/upload-image"})
@RequiredArgsConstructor
public class RecipeImageController {

    private final RecipeImageStorageService recipeImageStorageService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<RecipeImageUploadResponse> upload(@RequestPart("file") MultipartFile file) {
        return ResponseEntity.status(HttpStatus.CREATED).body(recipeImageStorageService.uploadRecipeImage(file));
    }
}
