package com.mss301.userservice.api.dto;

import com.mss301.userservice.domain.AllergySeverity;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Builder;

@Builder
public record CreateUserAllergyRequest(
        @NotNull
        @Positive
        Long allergenId,

        @NotNull
        AllergySeverity severity
) {
}
