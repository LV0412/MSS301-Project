package com.mss301.userservice.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.NutritionGoalOutdatedReason;
import com.mss301.userservice.entity.NutritionGoalStatus;
import com.mss301.userservice.repository.NutritionGoalRepository;
import java.math.BigDecimal;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NutritionGoalFreshnessServiceTest {

    @Mock
    private NutritionGoalRepository nutritionGoalRepository;

    @InjectMocks
    private NutritionGoalFreshnessService nutritionGoalFreshnessService;

    @Test
    void marksConfiguredGoalOutdatedWithHealthProfileReason() {
        Long userId = 7L;
        NutritionGoal goal = NutritionGoal.builder()
                .goalConfigured(true)
                .targetWeight(BigDecimal.valueOf(68))
                .durationWeeks(24)
                .weeklyRateKg(BigDecimal.valueOf(0.5))
                .dailyCaloriesGoal(BigDecimal.valueOf(1800))
                .status(NutritionGoalStatus.CURRENT)
                .build();
        when(nutritionGoalRepository.findByUserUserId(userId)).thenReturn(Optional.of(goal));

        nutritionGoalFreshnessService.markOutdatedForHealthProfileChange(userId);

        assertThat(goal.getStatus()).isEqualTo(NutritionGoalStatus.OUTDATED);
        assertThat(goal.getOutdatedReason())
                .isEqualTo(NutritionGoalOutdatedReason.HEALTH_PROFILE_CHANGED);
        assertThat(goal.getTargetWeight()).isEqualByComparingTo("68");
        assertThat(goal.getDurationWeeks()).isEqualTo(24);
        assertThat(goal.getWeeklyRateKg()).isEqualByComparingTo("0.5");
        assertThat(goal.getDailyCaloriesGoal()).isEqualByComparingTo("1800");
    }
}
