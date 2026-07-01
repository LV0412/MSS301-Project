package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.Gender;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import lombok.Builder;

@Schema(description = "Update User Request")
@Builder
public record UpdateUserRequest(
        @Email
        @Size(max = 255)
        String email,

        @Size(max = 255)
        String passwordHash,

        @Size(max = 255)
        String fullName,

        @Past
        LocalDate dob,

        Gender gender
) {
}
