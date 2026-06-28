package com.mss301.userservice.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Builder;

@Builder
public record UpdateFavoriteRequest(
        @NotNull
        @Positive
        Long recipeId
) {
}
