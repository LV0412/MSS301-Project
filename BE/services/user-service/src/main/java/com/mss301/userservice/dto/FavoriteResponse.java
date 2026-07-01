package com.mss301.userservice.dto;

import lombok.Builder;

@Builder
public record FavoriteResponse(
        Long favoriteId,
        Long userId,
        Long recipeId
) {
}
