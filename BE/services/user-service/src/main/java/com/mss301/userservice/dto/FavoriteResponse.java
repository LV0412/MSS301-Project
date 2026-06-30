package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import lombok.Builder;

@Schema(description = "Favorite Response")
@Builder
public record FavoriteResponse(
        Long favoriteId,
        Long userId,
        Long recipeId
) {
}
