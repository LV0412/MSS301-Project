package com.mss301.userservice.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
public record UpdateDietPreferenceRequest(
        @NotBlank
        @Size(max = 100)
        String dietType
) {
}
