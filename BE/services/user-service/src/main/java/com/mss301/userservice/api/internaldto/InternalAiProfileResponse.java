package com.mss301.userservice.api.internaldto;

import java.util.List;
import lombok.Builder;

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
