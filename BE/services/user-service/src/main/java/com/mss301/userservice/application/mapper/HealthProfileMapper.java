package com.mss301.userservice.application.mapper;

import com.mss301.userservice.api.dto.CreateHealthProfileRequest;
import com.mss301.userservice.api.dto.HealthProfileResponse;
import com.mss301.userservice.api.dto.UpdateHealthProfileRequest;
import com.mss301.userservice.domain.HealthProfile;
import com.mss301.userservice.domain.User;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.stereotype.Component;

@Component
public class HealthProfileMapper {

    public HealthProfile toEntity(CreateHealthProfileRequest request, User user) {
        HealthProfile healthProfile = HealthProfile.builder()
                .user(user)
                .height(request.height())
                .weight(request.weight())
                .activityLevel(request.activityLevel())
                .build();
        recalculateBmi(healthProfile);
        return healthProfile;
    }

    public void updateEntity(HealthProfile healthProfile, UpdateHealthProfileRequest request) {
        boolean shouldRecalculateBmi = false;

        if (request.height() != null) {
            healthProfile.setHeight(request.height());
            shouldRecalculateBmi = true;
        }
        if (request.weight() != null) {
            healthProfile.setWeight(request.weight());
            shouldRecalculateBmi = true;
        }
        if (request.activityLevel() != null) {
            healthProfile.setActivityLevel(request.activityLevel());
        }
        if (shouldRecalculateBmi) {
            recalculateBmi(healthProfile);
        }
    }

    public HealthProfileResponse toResponse(HealthProfile healthProfile) {
        return HealthProfileResponse.builder()
                .profileId(healthProfile.getProfileId())
                .userId(healthProfile.getUser().getUserId())
                .height(healthProfile.getHeight())
                .weight(healthProfile.getWeight())
                .activityLevel(healthProfile.getActivityLevel())
                .bmi(healthProfile.getBmi())
                .build();
    }

    private void recalculateBmi(HealthProfile healthProfile) {
        BigDecimal heightInMeters = healthProfile.getHeight()
                .divide(BigDecimal.valueOf(100), 6, RoundingMode.HALF_UP);
        BigDecimal bmi = healthProfile.getWeight()
                .divide(heightInMeters.pow(2), 2, RoundingMode.HALF_UP);

        healthProfile.setBmi(bmi);
    }
}
