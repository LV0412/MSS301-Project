package com.mss301.userservice.api.dto;

import lombok.Builder;

@Builder
public record FavoriteResponse(
        Long favoriteId,
        Long userId,
        Long recipeId
) {
}
