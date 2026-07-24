package com.mss301.userservice.client;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record AiGeneratedMealPlanResponse(
        @JsonProperty("user_id")
        Long userId,
        @JsonProperty("plan_date")
        LocalDate planDate,
        String title,
        String status,
        @JsonProperty("match_score")
        BigDecimal matchScore,
        List<String> warnings,
        List<AiGeneratedMealPlanEntry> entries
) {
}
