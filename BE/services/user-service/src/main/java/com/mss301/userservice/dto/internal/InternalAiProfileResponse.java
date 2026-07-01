package com.mss301.userservice.dto.internal;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import lombok.Builder;

@Schema(description = "Internal AI Profile Response")
@Builder
public record InternalAiProfileResponse(
        InternalUserResponse user,
        InternalHealthProfileResponse healthProfile,
        InternalHealthProfileStatusResponse healthProfileStatus,
        InternalNutritionGoalResponse nutritionGoal,
        List<InternalDietPreferenceResponse> dietPreferences,
        List<InternalUserAllergyResponse> allergies,
        List<InternalFoodLogResponse> foodLogs
) {
}
