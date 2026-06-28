package com.mss301.userservice.dto;

import com.mss301.userservice.entity.AllergySeverity;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Builder;

@Builder
public record UpdateUserAllergyRequest(
        @NotNull
        @Positive
        Long allergenId,

        @NotNull
        AllergySeverity severity
) {
}
