package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
@Schema(description = "Email request")
public record EmailRequest(
        @NotBlank
        @Email
        @Size(max = 255)
        @Schema(description = "Account email", example = "test@example.com")
        String email
) {
}
