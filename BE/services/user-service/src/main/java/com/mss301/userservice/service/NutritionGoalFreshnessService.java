package com.mss301.userservice.service;

import com.mss301.userservice.entity.NutritionGoalOutdatedReason;
import com.mss301.userservice.entity.NutritionGoalStatus;
import com.mss301.userservice.repository.NutritionGoalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class NutritionGoalFreshnessService {

    private final NutritionGoalRepository nutritionGoalRepository;

    @Transactional
    public void markOutdatedForHealthProfileChange(Long userId) {
        nutritionGoalRepository.findByUserUserId(userId).ifPresent(goal -> {
            if (goal.isGoalConfigured()) {
                goal.setStatus(NutritionGoalStatus.OUTDATED);
                goal.setOutdatedReason(NutritionGoalOutdatedReason.HEALTH_PROFILE_CHANGED);
            }
        });
    }
}
