package com.mss301.userservice.api.dto;

import com.mss301.userservice.domain.Gender;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.Builder;

@Builder
public record CreateUserRequest(
        @NotBlank
        @Email
        @Size(max = 255)
        String email,

        @NotBlank
        @Size(max = 255)
        String passwordHash,

        @NotBlank
        @Size(max = 255)
        String fullName,

        @Past
        LocalDate dob,

        @NotNull
        Gender gender
) {
}
