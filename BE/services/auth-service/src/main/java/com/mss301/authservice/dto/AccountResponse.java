package com.mss301.authservice.dto;

import com.mss301.authservice.entity.AccountRole;
import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.AuthProvider;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;
import lombok.Builder;

@Builder
@Schema(description = "Account response")
public record AccountResponse(
        @Schema(description = "Account ID", example = "1")
        Long accountId,

        @Schema(description = "Account email", example = "test@example.com")
        String email,

        @Schema(description = "User display name", example = "Test User")
        String fullName,

        @Schema(description = "Account role", example = "USER")
        AccountRole role,

        @Schema(description = "Account status", example = "ACTIVE")
        AccountStatus status,

        @Schema(description = "Whether email has been verified", example = "true")
        Boolean emailVerified,

        @Schema(description = "Authentication provider", example = "LOCAL")
        AuthProvider provider,

        @Schema(description = "Whether this account is linked to Google", example = "true")
        Boolean googleLinked,

        @Schema(description = "Created timestamp")
        LocalDateTime createdAt,

        @Schema(description = "Updated timestamp")
        LocalDateTime updatedAt
) {
}
