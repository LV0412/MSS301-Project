package com.mss301.authservice.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
public record EmailRequest(
        @NotBlank
        @Email
        String email
) {
}
