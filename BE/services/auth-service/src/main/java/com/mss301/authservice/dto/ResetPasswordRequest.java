package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;

@Builder
@Schema(description = "Reset password request")
public record ResetPasswordRequest(
        @NotBlank
        @Schema(description = "Password reset token received by email or console fallback", example = "NFPYV6eSz7lG1Q2wX8XUCk-ctn7nU0G8wAg2TjJxnQw")
        String resetToken,

        @NotBlank
        @Size(min = 8, max = 100)
        @Schema(description = "New password", example = "NewPassword@123")
        String newPassword
) {
}
