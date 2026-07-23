package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateDietPreferenceRequest;
import com.mss301.userservice.dto.DietPreferenceResponse;
import com.mss301.userservice.dto.UpdateDietPreferenceRequest;
import java.util.List;

public interface DietPreferenceService {

    DietPreferenceResponse addDietPreference(Long userId, CreateDietPreferenceRequest request);

    List<DietPreferenceResponse> getDietPreferences(Long userId);

    DietPreferenceResponse updateDietPreference(
            Long userId,
            Long preferenceId,
            UpdateDietPreferenceRequest request);

    void deleteDietPreference(Long userId, Long preferenceId);
}
