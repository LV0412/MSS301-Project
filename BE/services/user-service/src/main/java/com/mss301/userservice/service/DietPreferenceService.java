package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateDietPreferenceRequest;
import com.mss301.userservice.dto.DietPreferenceResponse;
import com.mss301.userservice.dto.UpdateDietPreferenceRequest;
import com.mss301.userservice.entity.DietPreference;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.DietPreferenceNotFoundException;
import com.mss301.userservice.exception.DuplicateDietPreferenceException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.DietPreferenceRepository;
import com.mss301.userservice.repository.UserRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class DietPreferenceService {

    private final DietPreferenceRepository dietPreferenceRepository;
    private final UserRepository userRepository;

    public DietPreferenceResponse addDietPreference(Long userId, CreateDietPreferenceRequest request) {
        User user = findUser(userId);
        String dietType = normalizeDietType(request.dietType());
        ensureDietTypeIsAvailable(userId, dietType, null);

        DietPreference dietPreference = DietPreference.builder()
                .user(user)
                .dietType(dietType)
                .build();

        return toResponse(dietPreferenceRepository.save(dietPreference));
    }

    @Transactional(readOnly = true)
    public List<DietPreferenceResponse> getDietPreferences(Long userId) {
        findUser(userId);
        return dietPreferenceRepository.findAllByUserUserId(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    public DietPreferenceResponse updateDietPreference(
            Long userId,
            Long preferenceId,
            UpdateDietPreferenceRequest request) {
        DietPreference dietPreference = findDietPreference(userId, preferenceId);
        String dietType = normalizeDietType(request.dietType());
        ensureDietTypeIsAvailable(userId, dietType, preferenceId);

        dietPreference.setDietType(dietType);
        return toResponse(dietPreferenceRepository.save(dietPreference));
    }

    public void deleteDietPreference(Long userId, Long preferenceId) {
        DietPreference dietPreference = findDietPreference(userId, preferenceId);
        dietPreferenceRepository.delete(dietPreference);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private DietPreference findDietPreference(Long userId, Long preferenceId) {
        return dietPreferenceRepository.findByPreferenceIdAndUserUserId(preferenceId, userId)
                .orElseThrow(() -> new DietPreferenceNotFoundException(preferenceId, userId));
    }

    private void ensureDietTypeIsAvailable(Long userId, String dietType, Long currentPreferenceId) {
        dietPreferenceRepository.findByUserUserIdAndDietTypeIgnoreCase(userId, dietType)
                .filter(existing -> !existing.getPreferenceId().equals(currentPreferenceId))
                .ifPresent(existing -> {
                    throw new DuplicateDietPreferenceException(userId, dietType);
                });
    }

    private String normalizeDietType(String dietType) {
        return dietType.trim().toUpperCase();
    }

    private DietPreferenceResponse toResponse(DietPreference dietPreference) {
        return DietPreferenceResponse.builder()
                .preferenceId(dietPreference.getPreferenceId())
                .userId(dietPreference.getUser().getUserId())
                .dietType(dietPreference.getDietType())
                .build();
    }
}
