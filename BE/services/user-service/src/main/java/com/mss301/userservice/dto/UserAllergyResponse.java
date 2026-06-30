package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.AllergySeverity;
import lombok.Builder;

@Schema(description = "User Allergy Response")
@Builder
public record UserAllergyResponse(
        Long allergyId,
        Long userId,
        Long allergenId,
        AllergySeverity severity
) {
}
