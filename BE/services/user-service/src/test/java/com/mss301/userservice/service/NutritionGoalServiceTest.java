package com.mss301.userservice.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.UpdateNutritionGoalRequest;
import com.mss301.userservice.entity.ActivityLevel;
import com.mss301.userservice.entity.Gender;
import com.mss301.userservice.entity.GoalType;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.InvalidNutritionGoalException;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NutritionGoalServiceTest {

    @Mock
    private NutritionGoalRepository nutritionGoalRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private HealthProfileRepository healthProfileRepository;

    @InjectMocks
    private NutritionGoalService nutritionGoalService;

    @Test
    void createNutritionGoalPersistsWeightGoalPlanFields() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(170), BigDecimal.valueOf(80), ActivityLevel.MODERATE);
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(68),
                24,
                BigDecimal.valueOf(0.5),
                null,
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));
        when(nutritionGoalRepository.save(any(NutritionGoal.class))).thenAnswer(invocation -> {
            NutritionGoal nutritionGoal = invocation.getArgument(0);
            nutritionGoal.setGoalId(1L);
            return nutritionGoal;
        });

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.goalType()).isEqualTo(GoalType.LOSE_WEIGHT);
        assertThat(response.targetWeight()).isEqualByComparingTo("68");
        assertThat(response.durationWeeks()).isEqualTo(24);
        assertThat(response.weeklyRateKg()).isEqualByComparingTo("0.5");
        assertThat(response.recommendedCalories()).isEqualByComparingTo("2112.13");
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("2112.13");
    }

    @Test
    void updateNutritionGoalUpdatesWeightGoalPlanFields() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(165), BigDecimal.valueOf(70), ActivityLevel.LIGHT);
        NutritionGoal existingGoal = NutritionGoal.builder()
                .goalId(1L)
                .user(user)
                .goalType(GoalType.MAINTAIN)
                .targetWeight(BigDecimal.valueOf(70))
                .durationWeeks(12)
                .weeklyRateKg(BigDecimal.ZERO)
                .recommendedCalories(BigDecimal.valueOf(2000))
                .dailyCaloriesGoal(BigDecimal.valueOf(2200))
                .protein(BigDecimal.valueOf(120))
                .carbs(BigDecimal.valueOf(250))
                .fat(BigDecimal.valueOf(70))
                .build();
        UpdateNutritionGoalRequest request = new UpdateNutritionGoalRequest(
                GoalType.GAIN_WEIGHT,
                BigDecimal.valueOf(75),
                20,
                BigDecimal.valueOf(0.25),
                BigDecimal.valueOf(2300),
                null,
                null,
                null);

        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.of(existingGoal));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));
        when(nutritionGoalRepository.save(any(NutritionGoal.class))).thenAnswer(invocation -> invocation.getArgument(0));

        NutritionGoalResponse response = nutritionGoalService.updateNutritionGoal(userId, request);

        assertThat(response.goalType()).isEqualTo(GoalType.GAIN_WEIGHT);
        assertThat(response.targetWeight()).isEqualByComparingTo("75");
        assertThat(response.durationWeeks()).isEqualTo(20);
        assertThat(response.weeklyRateKg()).isEqualByComparingTo("0.25");
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("2300");
    }

    @Test
    void createNutritionGoalUsesAverageBmrForOtherGender() {
        Long userId = 7L;
        User user = user(userId, Gender.OTHER, 30);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(170), BigDecimal.valueOf(70), ActivityLevel.SEDENTARY);
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.MAINTAIN,
                BigDecimal.valueOf(70),
                12,
                BigDecimal.ZERO,
                null,
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));
        when(nutritionGoalRepository.save(any(NutritionGoal.class))).thenAnswer(invocation -> {
            NutritionGoal nutritionGoal = invocation.getArgument(0);
            nutritionGoal.setGoalId(1L);
            return nutritionGoal;
        });

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.recommendedCalories()).isEqualByComparingTo("1841.40");
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("1841.40");
    }

    @Test
    void createNutritionGoalDefaultsMissingGoalTypeToUnconfiguredMaintain() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(165), BigDecimal.valueOf(70), ActivityLevel.LIGHT);
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                null,
                null,
                null,
                null,
                null,
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));
        when(nutritionGoalRepository.save(any(NutritionGoal.class))).thenAnswer(invocation -> {
            NutritionGoal nutritionGoal = invocation.getArgument(0);
            nutritionGoal.setGoalId(1L);
            return nutritionGoal;
        });

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.goalType()).isEqualTo(GoalType.MAINTAIN);
        assertThat(response.targetWeight()).isNull();
        assertThat(response.durationWeeks()).isNull();
        assertThat(response.weeklyRateKg()).isNull();
        assertThat(response.goalConfigured()).isFalse();
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("1966.59");
    }

    @Test
    void createNutritionGoalRejectsDailyCaloriesBelowBmr() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(170), BigDecimal.valueOf(80), ActivityLevel.MODERATE);
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(68),
                24,
                BigDecimal.valueOf(0.5),
                BigDecimal.valueOf(1200),
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));

        assertThatThrownBy(() -> nutritionGoalService.createNutritionGoal(userId, request))
                .isInstanceOf(InvalidNutritionGoalException.class)
                .hasMessage("Daily calories goal must not be lower than calculated BMR");
    }

    @Test
    void createNutritionGoalRejectsExtremeTargetBmi() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(170), BigDecimal.valueOf(80), ActivityLevel.MODERATE);
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(45),
                35,
                BigDecimal.valueOf(1),
                null,
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));

        assertThatThrownBy(() -> nutritionGoalService.createNutritionGoal(userId, request))
                .isInstanceOf(InvalidNutritionGoalException.class)
                .hasMessage("Target BMI must be between 16 and 35");
    }

    @Test
    void createNutritionGoalRejectsMissingPlanForWeightChangeGoal() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(170), BigDecimal.valueOf(80), ActivityLevel.MODERATE);
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                null,
                null,
                null,
                null,
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));

        assertThatThrownBy(() -> nutritionGoalService.createNutritionGoal(userId, request))
                .isInstanceOf(InvalidNutritionGoalException.class)
                .hasMessage("Target weight, duration weeks, and weekly rate are required for LOSE_WEIGHT");
    }

    @Test
    void getNutritionGoalFallsBackToMaintainForLegacyInvalidPlan() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(BigDecimal.valueOf(160), BigDecimal.valueOf(80), ActivityLevel.SEDENTARY);
        NutritionGoal legacyGoal = NutritionGoal.builder()
                .goalId(1L)
                .user(user)
                .goalType(GoalType.GAIN_WEIGHT)
                .targetWeight(BigDecimal.ZERO)
                .durationWeeks(12)
                .weeklyRateKg(BigDecimal.ZERO)
                .recommendedCalories(BigDecimal.valueOf(1500))
                .dailyCaloriesGoal(BigDecimal.valueOf(1500))
                .protein(BigDecimal.valueOf(90))
                .carbs(BigDecimal.valueOf(150))
                .fat(BigDecimal.valueOf(45))
                .build();

        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.of(legacyGoal));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));

        NutritionGoalResponse response = nutritionGoalService.getNutritionGoal(userId);

        assertThat(response.goalType()).isEqualTo(GoalType.MAINTAIN);
        assertThat(response.targetWeight()).isNull();
        assertThat(response.durationWeeks()).isNull();
        assertThat(response.weeklyRateKg()).isNull();
        assertThat(response.goalConfigured()).isFalse();
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("1798.80");
        assertThat(response.protein()).isEqualByComparingTo("90");
    }

    private User user(Long userId, Gender gender, int age) {
        return User.builder()
                .userId(userId)
                .dob(LocalDate.now().minusYears(age))
                .gender(gender)
                .build();
    }

    private HealthProfile healthProfile(BigDecimal height, BigDecimal weight, ActivityLevel activityLevel) {
        return HealthProfile.builder()
                .height(height)
                .weight(weight)
                .activityLevel(activityLevel)
                .build();
    }
}
