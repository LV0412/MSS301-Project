package com.mss301.userservice.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.mss301.userservice.dto.UpdateHealthProfileRequest;
import com.mss301.userservice.entity.ActivityLevel;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.mapper.HealthProfileMapper;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.service.impl.HealthProfileServiceImpl;
import java.math.BigDecimal;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class HealthProfileServiceTest {

    @Mock
    private HealthProfileRepository healthProfileRepository;

    @Mock
    private UserRepository userRepository;

    @Spy
    private HealthProfileMapper healthProfileMapper;

    @Mock
    private NutritionGoalFreshnessService nutritionGoalFreshnessService;

    @InjectMocks
    private HealthProfileServiceImpl healthProfileService;

    @Test
    void changingOnlyActivityLevelMarksNutritionGoalOutdated() {
        Long userId = 7L;
        HealthProfile profile = HealthProfile.builder()
                .profileId(3L)
                .user(User.builder().userId(userId).build())
                .height(BigDecimal.valueOf(170))
                .weight(BigDecimal.valueOf(80))
                .activityLevel(ActivityLevel.MODERATE)
                .bmi(BigDecimal.valueOf(27.68))
                .build();
        UpdateHealthProfileRequest request =
                new UpdateHealthProfileRequest(null, null, ActivityLevel.ACTIVE);

        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(profile));
        when(healthProfileRepository.save(any(HealthProfile.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        healthProfileService.updateHealthProfile(userId, request);

        verify(nutritionGoalFreshnessService).markOutdatedForHealthProfileChange(userId);
    }

    @Test
    void changingWeightOnlyMarksNutritionGoalOutdated() {
        Long userId = 7L;
        HealthProfile profile = HealthProfile.builder()
                .profileId(3L)
                .user(User.builder().userId(userId).build())
                .height(BigDecimal.valueOf(170))
                .weight(BigDecimal.valueOf(80))
                .activityLevel(ActivityLevel.MODERATE)
                .bmi(BigDecimal.valueOf(27.68))
                .build();
        UpdateHealthProfileRequest request =
                new UpdateHealthProfileRequest(null, BigDecimal.valueOf(79), null);

        when(healthProfileRepository.findByUserUserId(userId)).thenReturn(Optional.of(profile));
        when(healthProfileRepository.save(any(HealthProfile.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        healthProfileService.updateHealthProfile(userId, request);

        verify(nutritionGoalFreshnessService).markOutdatedForHealthProfileChange(userId);
    }
}
