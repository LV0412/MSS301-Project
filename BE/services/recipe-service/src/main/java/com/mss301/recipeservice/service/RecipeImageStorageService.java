package com.mss301.recipeservice.service;

import org.springframework.web.multipart.MultipartFile;

public interface RecipeImageStorageService {

    RecipeImageUploadResponse uploadRecipeImage(MultipartFile file);

    record RecipeImageUploadResponse(
            String imageUrl,
            String publicId,
            String originalFilename) {
    }
}
