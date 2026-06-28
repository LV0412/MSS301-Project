package com.mss301.userservice.api.internaldto;

import com.mss301.userservice.domain.Gender;
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
