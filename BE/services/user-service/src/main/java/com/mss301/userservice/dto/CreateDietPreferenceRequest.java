package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Schema(description = "Create Diet Preference Request")
@Builder
public record CreateDietPreferenceRequest(
        @NotBlank
        @Size(max = 100)
        String dietType
) {
}
