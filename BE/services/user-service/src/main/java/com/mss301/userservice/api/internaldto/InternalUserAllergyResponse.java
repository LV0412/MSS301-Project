package com.mss301.userservice.api.internaldto;

import com.mss301.userservice.domain.AllergySeverity;
import lombok.Builder;

@Builder
public record InternalUserAllergyResponse(
        Long allergyId,
        Long allergenId,
        AllergySeverity severity
) {
}
