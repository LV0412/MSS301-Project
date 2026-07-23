package com.mss301.userservice.service;

import com.mss301.userservice.dto.internal.InternalAiProfileResponse;
import com.mss301.userservice.dto.internal.InternalDietPreferenceResponse;
import com.mss301.userservice.dto.internal.InternalFoodLogResponse;
import com.mss301.userservice.dto.internal.InternalHealthProfileResponse;
import com.mss301.userservice.dto.internal.InternalHealthProfileStatusResponse;
import com.mss301.userservice.dto.internal.InternalNutritionGoalResponse;
import com.mss301.userservice.dto.internal.InternalUserAllergyResponse;
import com.mss301.userservice.dto.internal.InternalUserResponse;
import java.util.List;

public interface InternalUserService {

    InternalUserResponse getUser(Long userId);

    InternalHealthProfileResponse getHealthProfile(Long userId);

    InternalHealthProfileStatusResponse getHealthProfileStatus(Long userId);

    InternalNutritionGoalResponse getNutritionGoal(Long userId);

    List<InternalDietPreferenceResponse> getDietPreferences(Long userId);

    List<InternalUserAllergyResponse> getUserAllergies(Long userId);

    List<InternalFoodLogResponse> getFoodLogs(Long userId);

    InternalAiProfileResponse getAiProfile(Long userId);
}
