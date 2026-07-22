package com.mss301.recipeservice.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.mss301.recipeservice.config.CloudinaryProperties;
import com.mss301.recipeservice.exception.BusinessRuleViolationException;
import com.mss301.recipeservice.exception.ImageStorageException;
import com.mss301.recipeservice.service.RecipeImageStorageService;
import java.io.IOException;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RecipeImageStorageServiceImpl implements RecipeImageStorageService {

    private final Cloudinary cloudinary;
    private final CloudinaryProperties properties;

    public RecipeImageUploadResponse uploadRecipeImage(MultipartFile file) {
        validateFile(file);

        if (!properties.isEnabled()) {
            throw new ImageStorageException("Cloudinary upload is disabled. Set APP_CLOUDINARY_ENABLED=true.");
        }
        if (isBlank(properties.getCloudName()) || isBlank(properties.getApiKey()) || isBlank(properties.getApiSecret())) {
            throw new ImageStorageException("Cloudinary credentials are missing. Check CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET.");
        }

        try {
            Map<?, ?> result = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap(
                    "folder", properties.getFolder(),
                    "resource_type", "image",
                    "use_filename", true,
                    "unique_filename", true,
                    "overwrite", false));

            Object secureUrl = result.get("secure_url");
            Object publicId = result.get("public_id");
            if (!(secureUrl instanceof String imageUrl) || imageUrl.isBlank()) {
                throw new ImageStorageException("Cloudinary did not return a secure image URL.");
            }

            return new RecipeImageUploadResponse(
                    imageUrl,
                    publicId instanceof String value ? value : null,
                    file.getOriginalFilename());
        } catch (IOException exception) {
            throw new ImageStorageException("Failed to upload image to Cloudinary.", exception);
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessRuleViolationException("Image file is required");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("image/")) {
            throw new BusinessRuleViolationException("Only image files are supported");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
