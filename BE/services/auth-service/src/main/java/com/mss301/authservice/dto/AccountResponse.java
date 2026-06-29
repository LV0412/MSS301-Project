package com.mss301.authservice.dto;

import com.mss301.authservice.entity.AccountRole;
import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.AuthProvider;
import java.time.LocalDateTime;
import lombok.Builder;

@Builder
public record AccountResponse(
        Long accountId,
        String email,
        String fullName,
        AccountRole role,
        AccountStatus status,
        Boolean emailVerified,
        AuthProvider provider,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
