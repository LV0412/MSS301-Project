package com.mss301.authservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
public record EmailRequest(
        @NotBlank
        @Email
        @Size(max = 255)
        String email
) {
}
