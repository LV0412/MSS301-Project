package com.mss301.authservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Admin request for creating a local user account with the server-configured temporary password")
public record AdminCreateAccountRequest(
        @NotBlank @Email @Size(max = 255) String email,
        @NotBlank @Size(max = 255) String fullName
) {
}
