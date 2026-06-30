package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.AllergySeverity;
import lombok.Builder;

@Schema(description = "Internal User Allergy Response")
@Builder
public record InternalUserAllergyResponse(
        Long allergyId,
        Long allergenId,
        AllergySeverity severity
) {
}
