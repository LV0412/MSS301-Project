package com.mss301.userservice.service.impl;

import com.mss301.userservice.client.RecipeCatalogReferenceValidator;
import com.mss301.userservice.dto.CreateUserAllergyRequest;
import com.mss301.userservice.dto.UpdateUserAllergyRequest;
import com.mss301.userservice.dto.UserAllergyResponse;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.entity.UserAllergy;
import com.mss301.userservice.exception.DuplicateUserAllergyException;
import com.mss301.userservice.exception.UserAllergyNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.UserAllergyRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.service.UserAllergyService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class UserAllergyServiceImpl implements UserAllergyService {

    private final UserAllergyRepository userAllergyRepository;
    private final UserRepository userRepository;
    private final RecipeCatalogReferenceValidator recipeCatalogReferenceValidator;

    public UserAllergyResponse addAllergy(Long userId, CreateUserAllergyRequest request) {
        User user = findUser(userId);
        ensureAllergenIsAvailable(userId, request.allergenId(), null);
        recipeCatalogReferenceValidator.requireAllergenExists(request.allergenId());

        UserAllergy userAllergy = UserAllergy.builder()
                .user(user)
                .allergenId(request.allergenId())
                .severity(request.severity())
                .build();

        return toResponse(userAllergyRepository.save(userAllergy));
    }

    @Transactional(readOnly = true)
    public List<UserAllergyResponse> getAllergies(Long userId) {
        findUser(userId);
        return userAllergyRepository.findAllByUserUserId(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    public UserAllergyResponse updateAllergy(
            Long userId,
            Long allergyId,
            UpdateUserAllergyRequest request) {
        UserAllergy userAllergy = findUserAllergy(userId, allergyId);
        ensureAllergenIsAvailable(userId, request.allergenId(), allergyId);
        recipeCatalogReferenceValidator.requireAllergenExists(request.allergenId());

        userAllergy.setAllergenId(request.allergenId());
        userAllergy.setSeverity(request.severity());

        return toResponse(userAllergyRepository.save(userAllergy));
    }

    public void deleteAllergy(Long userId, Long allergyId) {
        UserAllergy userAllergy = findUserAllergy(userId, allergyId);
        userAllergyRepository.delete(userAllergy);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private UserAllergy findUserAllergy(Long userId, Long allergyId) {
        return userAllergyRepository.findByAllergyIdAndUserUserId(allergyId, userId)
                .orElseThrow(() -> new UserAllergyNotFoundException(allergyId, userId));
    }

    private void ensureAllergenIsAvailable(Long userId, Long allergenId, Long currentAllergyId) {
        userAllergyRepository.findByUserUserIdAndAllergenId(userId, allergenId)
                .filter(existing -> !existing.getAllergyId().equals(currentAllergyId))
                .ifPresent(existing -> {
                    throw new DuplicateUserAllergyException(userId, allergenId);
                });
    }

    private UserAllergyResponse toResponse(UserAllergy userAllergy) {
        return UserAllergyResponse.builder()
                .allergyId(userAllergy.getAllergyId())
                .userId(userAllergy.getUser().getUserId())
                .allergenId(userAllergy.getAllergenId())
                .severity(userAllergy.getSeverity())
                .build();
    }
}
