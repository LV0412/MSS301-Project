package com.mss301.userservice.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.mss301.userservice.client.RecipeCatalogReferenceValidator;
import com.mss301.userservice.dto.CreateUserAllergyRequest;
import com.mss301.userservice.entity.AllergySeverity;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.entity.UserAllergy;
import com.mss301.userservice.repository.UserAllergyRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.service.impl.UserAllergyServiceImpl;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class UserAllergyServiceTest {

    @Mock
    private UserAllergyRepository userAllergyRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RecipeCatalogReferenceValidator recipeCatalogReferenceValidator;

    @InjectMocks
    private UserAllergyServiceImpl userAllergyService;

    @Test
    void addAllergyVerifiesAllergenBeforeSaving() {
        Long userId = 7L;
        Long allergenId = 5L;
        User user = User.builder().userId(userId).build();
        CreateUserAllergyRequest request = new CreateUserAllergyRequest(allergenId, AllergySeverity.HIGH);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(userAllergyRepository.findByUserUserIdAndAllergenId(userId, allergenId)).thenReturn(Optional.empty());
        when(userAllergyRepository.save(any(UserAllergy.class))).thenAnswer(invocation -> {
            UserAllergy userAllergy = invocation.getArgument(0);
            userAllergy.setAllergyId(1L);
            return userAllergy;
        });

        userAllergyService.addAllergy(userId, request);

        verify(recipeCatalogReferenceValidator).requireAllergenExists(allergenId);
        verify(userAllergyRepository).save(any(UserAllergy.class));
    }
}
