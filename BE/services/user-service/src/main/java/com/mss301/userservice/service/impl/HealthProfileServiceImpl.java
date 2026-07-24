package com.mss301.userservice.service.impl;

import com.mss301.userservice.dto.CreateHealthProfileRequest;
import com.mss301.userservice.dto.HealthProfileResponse;
import com.mss301.userservice.dto.UpdateHealthProfileRequest;
import com.mss301.userservice.mapper.HealthProfileMapper;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.HealthProfileAlreadyExistsException;
import com.mss301.userservice.exception.HealthProfileNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.service.HealthProfileService;
import com.mss301.userservice.service.NutritionGoalFreshnessService;
import java.math.BigDecimal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class HealthProfileServiceImpl implements HealthProfileService {

    private final HealthProfileRepository healthProfileRepository;
    private final UserRepository userRepository;
    private final HealthProfileMapper healthProfileMapper;
    private final NutritionGoalFreshnessService nutritionGoalFreshnessService;

    public HealthProfileResponse createHealthProfile(Long userId, CreateHealthProfileRequest request) {
        if (healthProfileRepository.existsByUserUserId(userId)) {
            throw new HealthProfileAlreadyExistsException(userId);
        }

        User user = findUser(userId);
        HealthProfile healthProfile = healthProfileMapper.toEntity(request, user);

        return healthProfileMapper.toResponse(healthProfileRepository.save(healthProfile));
    }

    @Transactional(readOnly = true)
    public HealthProfileResponse getHealthProfile(Long userId) {
        return healthProfileMapper.toResponse(findHealthProfile(userId));
    }

    public HealthProfileResponse updateHealthProfile(Long userId, UpdateHealthProfileRequest request) {
        HealthProfile healthProfile = findHealthProfile(userId);
        boolean nutritionInputsChanged =
                hasChanged(healthProfile.getHeight(), request.height())
                        || hasChanged(healthProfile.getWeight(), request.weight())
                        || (request.activityLevel() != null
                                && request.activityLevel() != healthProfile.getActivityLevel());
        healthProfileMapper.updateEntity(healthProfile, request);
        HealthProfile savedProfile = healthProfileRepository.save(healthProfile);
        if (nutritionInputsChanged) {
            nutritionGoalFreshnessService.markOutdatedForHealthProfileChange(userId);
        }

        return healthProfileMapper.toResponse(savedProfile);
    }

    public void deleteHealthProfile(Long userId) {
        HealthProfile healthProfile = findHealthProfile(userId);
        healthProfileRepository.delete(healthProfile);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private HealthProfile findHealthProfile(Long userId) {
        return healthProfileRepository.findByUserUserId(userId)
                .orElseThrow(() -> new HealthProfileNotFoundException(userId));
    }

    private boolean hasChanged(BigDecimal currentValue, BigDecimal requestedValue) {
        return requestedValue != null
                && (currentValue == null || currentValue.compareTo(requestedValue) != 0);
    }
}
