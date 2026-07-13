package com.mss301.userservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.Gender;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Builder;

@Schema(description = "User Response")
@Builder
public record UserResponse(
        Long userId,
        Long authAccountId,
        String email,
        String fullName,
        LocalDate dob,
        Gender gender,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
