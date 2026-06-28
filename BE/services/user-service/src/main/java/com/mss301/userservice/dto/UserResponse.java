package com.mss301.userservice.dto;

import com.mss301.userservice.entity.Gender;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Builder;

@Builder
public record UserResponse(
        Long userId,
        String email,
        String fullName,
        LocalDate dob,
        Gender gender,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}
