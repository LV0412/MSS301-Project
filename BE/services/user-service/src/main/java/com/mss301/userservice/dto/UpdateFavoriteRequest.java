package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Builder;

@Schema(description = "Update Favorite Request")
@Builder
public record UpdateFavoriteRequest(
        @NotNull
        @Positive
        Long recipeId
) {
}
