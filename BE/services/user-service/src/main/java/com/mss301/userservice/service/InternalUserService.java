package com.mss301.userservice.service;

import com.mss301.userservice.dto.internal.HealthProfileCompletionStatus;
import com.mss301.userservice.dto.internal.InternalAiProfileResponse;
import com.mss301.userservice.dto.internal.InternalDietPreferenceResponse;
import com.mss301.userservice.dto.internal.InternalFoodLogResponse;
import com.mss301.userservice.dto.internal.InternalHealthProfileResponse;
import com.mss301.userservice.dto.internal.InternalHealthProfileStatusResponse;
import com.mss301.userservice.dto.internal.InternalNutritionGoalResponse;
import com.mss301.userservice.dto.internal.InternalUserAllergyResponse;
import com.mss301.userservice.dto.internal.InternalUserResponse;
import com.mss301.userservice.entity.DietPreference;
import com.mss301.userservice.entity.FoodLog;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.entity.UserAllergy;
import com.mss301.userservice.exception.HealthProfileNotFoundException;
import com.mss301.userservice.exception.NutritionGoalNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.DietPreferenceRepository;
import com.mss301.userservice.repository.FoodLogRepository;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserAllergyRepository;
import com.mss301.userservice.repository.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class InternalUserService {

    private final UserRepository userRepository;
    private final HealthProfileRepository healthProfileRepository;
    private final NutritionGoalRepository nutritionGoalRepository;
    private final DietPreferenceRepository dietPreferenceRepository;
    private final UserAllergyRepository userAllergyRepository;
    private final FoodLogRepository foodLogRepository;

    public InternalUserResponse getUser(Long userId) {
        return toUserResponse(findUser(userId));
    }

    public InternalHealthProfileResponse getHealthProfile(Long userId) {
        findUser(userId);
        return healthProfileRepository.findByUserUserId(userId)
                .map(this::toHealthProfileResponse)
                .orElseThrow(() -> new HealthProfileNotFoundException(userId));
    }

    public InternalHealthProfileStatusResponse getHealthProfileStatus(Long userId) {
        findUser(userId);
        HealthProfileCompletionStatus status = healthProfileRepository.findByUserUserId(userId)
                .filter(this::isCompleteHealthProfile)
                .map(healthProfile -> HealthProfileCompletionStatus.COMPLETE)
                .orElse(HealthProfileCompletionStatus.INCOMPLETE);

        return InternalHealthProfileStatusResponse.builder()
                .userId(userId)
                .status(status)
                .build();
    }

    public InternalNutritionGoalResponse getNutritionGoal(Long userId) {
        findUser(userId);
        return nutritionGoalRepository.findByUserUserId(userId)
                .map(this::toNutritionGoalResponse)
                .orElseThrow(() -> new NutritionGoalNotFoundException(userId));
    }

    public List<InternalDietPreferenceResponse> getDietPreferences(Long userId) {
        findUser(userId);
        return dietPreferenceRepository.findAllByUserUserId(userId).stream()
                .map(this::toDietPreferenceResponse)
                .toList();
    }

    public List<InternalUserAllergyResponse> getUserAllergies(Long userId) {
        findUser(userId);
        return userAllergyRepository.findAllByUserUserId(userId).stream()
                .map(this::toUserAllergyResponse)
                .toList();
    }

    public List<InternalFoodLogResponse> getFoodLogs(Long userId) {
        findUser(userId);
        return foodLogRepository.findAllByUserUserId(userId).stream()
                .map(this::toFoodLogResponse)
                .toList();
    }

    public InternalAiProfileResponse getAiProfile(Long userId) {
        User user = findUser(userId);

        return InternalAiProfileResponse.builder()
                .user(toUserResponse(user))
                .healthProfile(healthProfileRepository.findByUserUserId(userId)
                        .map(this::toHealthProfileResponse)
                        .orElse(null))
                .healthProfileStatus(getHealthProfileStatus(userId))
                .nutritionGoal(nutritionGoalRepository.findByUserUserId(userId)
                        .map(this::toNutritionGoalResponse)
                        .orElse(null))
                .dietPreferences(getDietPreferences(userId))
                .allergies(getUserAllergies(userId))
                .foodLogs(getFoodLogs(userId))
                .build();
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private boolean isCompleteHealthProfile(HealthProfile healthProfile) {
        return healthProfile.getHeight() != null
                && healthProfile.getWeight() != null
                && healthProfile.getActivityLevel() != null;
    }

    private InternalUserResponse toUserResponse(User user) {
        return InternalUserResponse.builder()
                .userId(user.getUserId())
                .fullName(user.getFullName())
                .dob(user.getDob())
                .gender(user.getGender())
                .build();
    }

    private InternalHealthProfileResponse toHealthProfileResponse(HealthProfile healthProfile) {
        return InternalHealthProfileResponse.builder()
                .height(healthProfile.getHeight())
                .weight(healthProfile.getWeight())
                .activityLevel(healthProfile.getActivityLevel())
                .bmi(healthProfile.getBmi())
                .build();
    }

    private InternalNutritionGoalResponse toNutritionGoalResponse(NutritionGoal nutritionGoal) {
        return InternalNutritionGoalResponse.builder()
                .goalType(nutritionGoal.getGoalType())
                .targetWeight(nutritionGoal.getTargetWeight())
                .durationWeeks(nutritionGoal.getDurationWeeks())
                .weeklyRateKg(nutritionGoal.getWeeklyRateKg())
                .recommendedCalories(nutritionGoal.getRecommendedCalories())
                .dailyCaloriesGoal(nutritionGoal.getDailyCaloriesGoal())
                .calories(nutritionGoal.getDailyCaloriesGoal())
                .protein(nutritionGoal.getProtein())
                .carbs(nutritionGoal.getCarbs())
                .fat(nutritionGoal.getFat())
                .build();
    }

    private InternalDietPreferenceResponse toDietPreferenceResponse(DietPreference dietPreference) {
        return InternalDietPreferenceResponse.builder()
                .preferenceId(dietPreference.getPreferenceId())
                .dietType(dietPreference.getDietType())
                .build();
    }

    private InternalUserAllergyResponse toUserAllergyResponse(UserAllergy userAllergy) {
        return InternalUserAllergyResponse.builder()
                .allergyId(userAllergy.getAllergyId())
                .allergenId(userAllergy.getAllergenId())
                .severity(userAllergy.getSeverity())
                .build();
    }

    private InternalFoodLogResponse toFoodLogResponse(FoodLog foodLog) {
        return InternalFoodLogResponse.builder()
                .logId(foodLog.getLogId())
                .recipeId(foodLog.getRecipeId())
                .quantity(foodLog.getQuantity())
                .mealType(foodLog.getMealType())
                .logDate(foodLog.getLogDate())
                .build();
    }
}
