package com.mss301.userservice.dto.internal;

import com.mss301.userservice.entity.Gender;
import java.time.LocalDate;
import lombok.Builder;

@Builder
public record InternalUserResponse(
        Long userId,
        String fullName,
        LocalDate dob,
        Gender gender
) {
}
