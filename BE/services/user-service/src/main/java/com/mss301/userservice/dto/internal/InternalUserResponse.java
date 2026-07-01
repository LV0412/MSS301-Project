package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import com.mss301.userservice.entity.Gender;
import java.time.LocalDate;
import lombok.Builder;

@Schema(description = "Internal User Response")
@Builder
public record InternalUserResponse(
        Long userId,
        String fullName,
        LocalDate dob,
        Gender gender
) {
}
