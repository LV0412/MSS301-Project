package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
@Schema(description = "Change password request")
public record ChangePasswordRequest(
        @NotBlank
        @Size(max = 100)
        @Schema(description = "Current account password", example = "OldPassword@123")
        String currentPassword,

        @NotBlank
        @Size(min = 8, max = 100)
        @Schema(description = "New password", example = "NewPassword@123")
        String newPassword,

        @NotBlank
        @Size(min = 8, max = 100)
        @Schema(description = "Confirmation of the new password", example = "NewPassword@123")
        String confirmPassword
) {
}
