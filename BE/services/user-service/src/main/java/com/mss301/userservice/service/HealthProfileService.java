package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateHealthProfileRequest;
import com.mss301.userservice.dto.HealthProfileResponse;
import com.mss301.userservice.dto.UpdateHealthProfileRequest;

public interface HealthProfileService {

    HealthProfileResponse createHealthProfile(Long userId, CreateHealthProfileRequest request);

    HealthProfileResponse getHealthProfile(Long userId);

    HealthProfileResponse updateHealthProfile(Long userId, UpdateHealthProfileRequest request);

    void deleteHealthProfile(Long userId);
}
