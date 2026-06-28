package com.mss301.authservice.api.dto;

import com.mss301.authservice.domain.AccountRole;
import com.mss301.authservice.domain.AccountStatus;
import com.mss301.authservice.domain.AuthProvider;
import lombok.Builder;

@Builder
public record AccountResponse(
        Long accountId,
        String email,
        AuthProvider provider,
        AccountRole role,
        AccountStatus status,
        boolean emailVerified
) {
}
