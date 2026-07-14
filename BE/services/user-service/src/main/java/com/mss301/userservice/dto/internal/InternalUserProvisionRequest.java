package com.mss301.userservice.dto.internal;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record InternalUserProvisionRequest(
        @NotNull @Positive Long authAccountId,
        @NotBlank @Email @Size(max = 255) String email,
        @NotBlank @Size(max = 255) String fullName
) {
}
