package com.mss301.userservice.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.NutritionGoalPreviewResponse;
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
        assertThat(response.protein()).isEqualByComparingTo("105.61");
        assertThat(response.carbs()).isEqualByComparingTo("264.02");
        assertThat(response.fat()).isEqualByComparingTo("70.40");
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
    void createNutritionGoalDefaultsMissingGoalTypeToConfiguredMaintain() {
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
        assertThat(response.goalConfigured()).isTrue();
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("1966.59");
    }

    @Test
    void getNutritionGoalReturnsUnconfiguredResponseWhenRecordDoesNotExist() {
        Long userId = 7L;
        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.empty());

        NutritionGoalResponse response = nutritionGoalService.getNutritionGoal(userId);

        assertThat(response.goalConfigured()).isFalse();
        assertThat(response.goalType()).isNull();
        assertThat(response.targetWeight()).isNull();
        assertThat(response.durationWeeks()).isNull();
        assertThat(response.weeklyRateKg()).isNull();
        assertThat(response.recommendedCalories()).isNull();
        assertThat(response.dailyCaloriesGoal()).isNull();
        assertThat(response.protein()).isNull();
        assertThat(response.carbs()).isNull();
        assertThat(response.fat()).isNull();
        assertThat(response.warnings()).isEmpty();
    }

    @Test
    void getNutritionGoalKeepsPersistedMaintainGoalConfigured() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(165),
                BigDecimal.valueOf(70),
                ActivityLevel.LIGHT);
        NutritionGoal goal = NutritionGoal.builder()
                .goalId(1L)
                .user(user)
                .goalType(GoalType.MAINTAIN)
                .goalConfigured(true)
                .recommendedCalories(BigDecimal.valueOf(1900))
                .dailyCaloriesGoal(BigDecimal.valueOf(2000))
                .protein(BigDecimal.valueOf(100))
                .carbs(BigDecimal.valueOf(200))
                .fat(BigDecimal.valueOf(60))
                .build();

        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.of(goal));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));

        NutritionGoalResponse response = nutritionGoalService.getNutritionGoal(userId);

        assertThat(response.goalConfigured()).isTrue();
        assertThat(response.goalType()).isEqualTo(GoalType.MAINTAIN);
        assertThat(response.targetWeight()).isNull();
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("2000");
    }

    @Test
    void createNutritionGoalPreservesManualDailyCaloriesOverride() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(170),
                BigDecimal.valueOf(80),
                ActivityLevel.ACTIVE);
        CreateNutritionGoalRequest request = createRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(76),
                10,
                BigDecimal.valueOf(0.4),
                BigDecimal.valueOf(2400));

        stubCreate(userId, user, healthProfile);

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("2400.00");
        assertThat(response.dailyCaloriesGoal()).isNotEqualByComparingTo(response.recommendedCalories());
    }

    @Test
    void createNutritionGoalRejectsCalculatedWeeklyRateOutsideSafeRange() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(170),
                BigDecimal.valueOf(80),
                ActivityLevel.ACTIVE);
        CreateNutritionGoalRequest request = createRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(76),
                20,
                null,
                null);

        stubCreateWithoutSave(userId, user, healthProfile);

        assertThatThrownBy(() -> nutritionGoalService.createNutritionGoal(userId, request))
                .isInstanceOf(InvalidNutritionGoalException.class)
                .hasMessage("Weekly rate must be between 0.25 and 1.0 kg/week");
    }

    @Test
    void createNutritionGoalNormalizesMaintainPlanFields() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(170),
                BigDecimal.valueOf(80),
                ActivityLevel.MODERATE);
        CreateNutritionGoalRequest request = createRequest(
                GoalType.MAINTAIN,
                BigDecimal.valueOf(80),
                10,
                BigDecimal.valueOf(0.1),
                null);

        stubCreate(userId, user, healthProfile);

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.goalType()).isEqualTo(GoalType.MAINTAIN);
        assertThat(response.targetWeight()).isNull();
        assertThat(response.durationWeeks()).isNull();
        assertThat(response.weeklyRateKg()).isNull();
    }

    @Test
    void createNutritionGoalRejectsLoseWeightInWrongDirection() {
        assertWrongDirection(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(80),
                "Target weight must be lower than current weight for LOSE_WEIGHT");
    }

    @Test
    void createNutritionGoalRejectsGainWeightInWrongDirection() {
        assertWrongDirection(
                GoalType.GAIN_WEIGHT,
                BigDecimal.valueOf(75),
                "Target weight must be higher than current weight for GAIN_WEIGHT");
    }

    @Test
    void createNutritionGoalReturnsWarningForLowTargetBmi() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(180),
                BigDecimal.valueOf(70),
                ActivityLevel.ACTIVE);
        CreateNutritionGoalRequest request = createRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(55),
                30,
                BigDecimal.valueOf(0.5),
                null);

        stubCreate(userId, user, healthProfile);

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.warnings()).singleElement()
                .asString()
                .contains("below 18.5");
    }

    @Test
    void createNutritionGoalReturnsWarningForHighTargetBmi() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(160),
                BigDecimal.valueOf(70),
                ActivityLevel.ACTIVE);
        CreateNutritionGoalRequest request = createRequest(
                GoalType.GAIN_WEIGHT,
                BigDecimal.valueOf(80),
                20,
                BigDecimal.valueOf(0.5),
                null);

        stubCreate(userId, user, healthProfile);

        NutritionGoalResponse response = nutritionGoalService.createNutritionGoal(userId, request);

        assertThat(response.warnings()).singleElement()
                .asString()
                .contains("above 30");
    }

    @Test
    void createNutritionGoalRejectsTargetBmiAboveAbsoluteMaximum() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(160),
                BigDecimal.valueOf(80),
                ActivityLevel.ACTIVE);
        CreateNutritionGoalRequest request = createRequest(
                GoalType.GAIN_WEIGHT,
                BigDecimal.valueOf(90),
                20,
                BigDecimal.valueOf(0.5),
                null);

        stubCreateWithoutSave(userId, user, healthProfile);

        assertThatThrownBy(() -> nutritionGoalService.createNutritionGoal(userId, request))
                .isInstanceOf(InvalidNutritionGoalException.class)
                .hasMessage("Target BMI must be between 16 and 35");
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
                .hasMessage("Target weight and duration weeks are required for LOSE_WEIGHT");
    }

    @Test
    void getNutritionGoalReturnsUnconfiguredForLegacyInvalidPlan() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
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

        NutritionGoalResponse response = nutritionGoalService.getNutritionGoal(userId);

        assertThat(response.goalType()).isNull();
        assertThat(response.targetWeight()).isNull();
        assertThat(response.durationWeeks()).isNull();
        assertThat(response.weeklyRateKg()).isNull();
        assertThat(response.goalConfigured()).isFalse();
        assertThat(response.dailyCaloriesGoal()).isNull();
        assertThat(response.protein()).isNull();
    }

    @Test
    void updateNutritionGoalCreatesRecordWhenMissing() {
        Long userId = 7L;
        User user = user(userId, Gender.FEMALE, 28);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(165),
                BigDecimal.valueOf(70),
                ActivityLevel.LIGHT);
        UpdateNutritionGoalRequest request = new UpdateNutritionGoalRequest(
                GoalType.MAINTAIN,
                BigDecimal.valueOf(60),
                12,
                BigDecimal.ONE,
                null,
                null,
                null,
                null);

        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.empty());
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));
        when(nutritionGoalRepository.save(any(NutritionGoal.class))).thenAnswer(invocation -> {
            NutritionGoal goal = invocation.getArgument(0);
            goal.setGoalId(9L);
            return goal;
        });

        NutritionGoalResponse response = nutritionGoalService.updateNutritionGoal(userId, request);

        assertThat(response.goalId()).isEqualTo(9L);
        assertThat(response.goalConfigured()).isTrue();
        assertThat(response.goalType()).isEqualTo(GoalType.MAINTAIN);
        assertThat(response.targetWeight()).isNull();
        assertThat(response.durationWeeks()).isNull();
        assertThat(response.weeklyRateKg()).isNull();
        assertThat(response.protein()).isEqualByComparingTo("98.33");
        assertThat(response.carbs()).isEqualByComparingTo("245.82");
        assertThat(response.fat()).isEqualByComparingTo("65.55");
    }

    @Test
    void previewNutritionGoalCalculatesPlanWithoutSaving() {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(170),
                BigDecimal.valueOf(80),
                ActivityLevel.ACTIVE);
        UpdateNutritionGoalRequest request = new UpdateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(76),
                10,
                null,
                BigDecimal.valueOf(2400),
                null,
                null,
                null);

        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.empty());
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));

        NutritionGoalPreviewResponse response = nutritionGoalService.previewNutritionGoal(userId, request);

        assertThat(response.weeklyRateKg()).isEqualByComparingTo("0.40");
        assertThat(response.dailyCaloriesGoal()).isEqualByComparingTo("2400.00");
        assertThat(response.protein()).isEqualByComparingTo("120.00");
        assertThat(response.carbs()).isEqualByComparingTo("300.00");
        assertThat(response.fat()).isEqualByComparingTo("80.00");
        verify(nutritionGoalRepository, never()).save(any(NutritionGoal.class));
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

    private CreateNutritionGoalRequest createRequest(
            GoalType goalType,
            BigDecimal targetWeight,
            int durationWeeks,
            BigDecimal weeklyRateKg,
            BigDecimal dailyCaloriesGoal) {
        return new CreateNutritionGoalRequest(
                goalType,
                targetWeight,
                durationWeeks,
                weeklyRateKg,
                dailyCaloriesGoal,
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));
    }

    private void stubCreate(Long userId, User user, HealthProfile healthProfile) {
        stubCreateWithoutSave(userId, user, healthProfile);
        when(nutritionGoalRepository.save(any(NutritionGoal.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
    }

    private void stubCreateWithoutSave(Long userId, User user, HealthProfile healthProfile) {
        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(healthProfile));
    }

    private void assertWrongDirection(GoalType goalType, BigDecimal targetWeight, String expectedMessage) {
        Long userId = 7L;
        User user = user(userId, Gender.MALE, 30);
        HealthProfile healthProfile = healthProfile(
                BigDecimal.valueOf(170),
                BigDecimal.valueOf(80),
                ActivityLevel.MODERATE);
        CreateNutritionGoalRequest request = createRequest(
                goalType,
                targetWeight,
                10,
                BigDecimal.valueOf(0.5),
                null);

        stubCreateWithoutSave(userId, user, healthProfile);

        assertThatThrownBy(() -> nutritionGoalService.createNutritionGoal(userId, request))
                .isInstanceOf(InvalidNutritionGoalException.class)
                .hasMessage(expectedMessage);
    }
}
