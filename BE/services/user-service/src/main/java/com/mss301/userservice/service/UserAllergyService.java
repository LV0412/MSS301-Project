package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateUserAllergyRequest;
import com.mss301.userservice.dto.UpdateUserAllergyRequest;
import com.mss301.userservice.dto.UserAllergyResponse;
import java.util.List;

public interface UserAllergyService {

    UserAllergyResponse addAllergy(Long userId, CreateUserAllergyRequest request);

    List<UserAllergyResponse> getAllergies(Long userId);

    UserAllergyResponse updateAllergy(
            Long userId,
            Long allergyId,
            UpdateUserAllergyRequest request);

    void deleteAllergy(Long userId, Long allergyId);
}
