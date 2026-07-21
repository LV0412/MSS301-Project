package com.mss301.userservice.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.UpdateNutritionGoalRequest;
import com.mss301.userservice.entity.GoalType;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserRepository;
import java.math.BigDecimal;
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

    @InjectMocks
    private NutritionGoalService nutritionGoalService;

    @Test
    void createNutritionGoalPersistsWeightGoalPlanFields() {
        Long userId = 7L;
        User user = User.builder().userId(userId).build();
        CreateNutritionGoalRequest request = new CreateNutritionGoalRequest(
                GoalType.LOSE_WEIGHT,
                BigDecimal.valueOf(68),
                24,
                BigDecimal.valueOf(0.5),
                BigDecimal.valueOf(1800),
                BigDecimal.valueOf(100),
                BigDecimal.valueOf(200),
                BigDecimal.valueOf(60));

        when(nutritionGoalRepository.existsByUserUserId(userId)).thenReturn(false);
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
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
    }

    @Test
    void updateNutritionGoalUpdatesWeightGoalPlanFields() {
        Long userId = 7L;
        User user = User.builder().userId(userId).build();
        NutritionGoal existingGoal = NutritionGoal.builder()
                .goalId(1L)
                .user(user)
                .goalType(GoalType.MAINTAIN)
                .targetWeight(BigDecimal.valueOf(70))
                .durationWeeks(12)
                .weeklyRateKg(BigDecimal.ZERO)
                .calories(BigDecimal.valueOf(2200))
                .protein(BigDecimal.valueOf(120))
                .carbs(BigDecimal.valueOf(250))
                .fat(BigDecimal.valueOf(70))
                .build();
        UpdateNutritionGoalRequest request = new UpdateNutritionGoalRequest(
                GoalType.GAIN_WEIGHT,
                BigDecimal.valueOf(75),
                20,
                BigDecimal.valueOf(0.25),
                null,
                null,
                null,
                null);

        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.of(existingGoal));
        when(nutritionGoalRepository.save(any(NutritionGoal.class))).thenAnswer(invocation -> invocation.getArgument(0));

        NutritionGoalResponse response = nutritionGoalService.updateNutritionGoal(userId, request);

        assertThat(response.goalType()).isEqualTo(GoalType.GAIN_WEIGHT);
        assertThat(response.targetWeight()).isEqualByComparingTo("75");
        assertThat(response.durationWeeks()).isEqualTo(20);
        assertThat(response.weeklyRateKg()).isEqualByComparingTo("0.25");
        assertThat(response.calories()).isEqualByComparingTo("2200");
    }
}
