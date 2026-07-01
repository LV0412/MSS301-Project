package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.AllergySeverity;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Builder;

@Schema(description = "Update User Allergy Request")
@Builder
public record UpdateUserAllergyRequest(
        @NotNull
        @Positive
        Long allergenId,

        @NotNull
        AllergySeverity severity
) {
}
