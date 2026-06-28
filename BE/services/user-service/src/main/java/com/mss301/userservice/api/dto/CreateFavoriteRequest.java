package com.mss301.userservice.api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Builder;

@Builder
public record CreateFavoriteRequest(
        @NotNull
        @Positive
        Long recipeId
) {
}
