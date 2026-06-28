package com.mss301.userservice.api;

import com.mss301.userservice.api.internaldto.InternalAiProfileResponse;
import com.mss301.userservice.api.internaldto.InternalDietPreferenceResponse;
import com.mss301.userservice.api.internaldto.InternalFoodLogResponse;
import com.mss301.userservice.api.internaldto.InternalHealthProfileResponse;
import com.mss301.userservice.api.internaldto.InternalHealthProfileStatusResponse;
import com.mss301.userservice.api.internaldto.InternalNutritionGoalResponse;
import com.mss301.userservice.api.internaldto.InternalUserAllergyResponse;
import com.mss301.userservice.api.internaldto.InternalUserResponse;
import com.mss301.userservice.application.InternalUserService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/internal")
@RequiredArgsConstructor
public class InternalController {

    private final InternalUserService internalUserService;

    @GetMapping("/users/{userId}")
    public InternalUserResponse getUser(@PathVariable Long userId) {
        return internalUserService.getUser(userId);
    }

    @GetMapping("/health-profiles/{userId}")
    public InternalHealthProfileResponse getHealthProfile(@PathVariable Long userId) {
        return internalUserService.getHealthProfile(userId);
    }

    @GetMapping("/health-profiles/{userId}/status")
    public InternalHealthProfileStatusResponse getHealthProfileStatus(@PathVariable Long userId) {
        return internalUserService.getHealthProfileStatus(userId);
    }

    @GetMapping("/nutrition-goals/{userId}")
    public InternalNutritionGoalResponse getNutritionGoal(@PathVariable Long userId) {
        return internalUserService.getNutritionGoal(userId);
    }

    @GetMapping("/diet-preferences/{userId}")
    public List<InternalDietPreferenceResponse> getDietPreferences(@PathVariable Long userId) {
        return internalUserService.getDietPreferences(userId);
    }

    @GetMapping("/user-allergies/{userId}")
    public List<InternalUserAllergyResponse> getUserAllergies(@PathVariable Long userId) {
        return internalUserService.getUserAllergies(userId);
    }

    @GetMapping("/food-logs/{userId}")
    public List<InternalFoodLogResponse> getFoodLogs(@PathVariable Long userId) {
        return internalUserService.getFoodLogs(userId);
    }

    @GetMapping("/ai-profile/{userId}")
    public InternalAiProfileResponse getAiProfile(@PathVariable Long userId) {
        return internalUserService.getAiProfile(userId);
    }
}
