package com.mss301.userservice.service;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.mss301.userservice.dto.CreateUserRequest;
import com.mss301.userservice.dto.UpdateUserRequest;
import com.mss301.userservice.entity.Gender;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.InvalidDateOfBirthException;
import com.mss301.userservice.repository.UserRepository;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class UserManagementServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserManagementService userManagementService;

    @Test
    void createUserRejectsDateOfBirthYoungerThanThirteen() {
        CreateUserRequest request = new CreateUserRequest(
                "teen@example.com",
                "hash",
                "Teen User",
                LocalDate.now().minusYears(13).plusDays(1),
                Gender.OTHER);

        assertThatThrownBy(() -> userManagementService.createUser(request))
                .isInstanceOf(InvalidDateOfBirthException.class)
                .hasMessage("User age must be between 13 and 120 years old");

        verify(userRepository, never()).existsByEmailIgnoreCase(request.email());
        verify(userRepository, never()).save(org.mockito.ArgumentMatchers.any(User.class));
    }

    @Test
    void updateUserRejectsDateOfBirthOlderThanOneHundredTwenty() {
        Long userId = 7L;
        User user = User.builder()
                .userId(userId)
                .email("user@example.com")
                .fullName("Existing User")
                .gender(Gender.OTHER)
                .build();
        UpdateUserRequest request = new UpdateUserRequest(
                null,
                null,
                null,
                LocalDate.now().minusYears(121),
                null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> userManagementService.updateUser(userId, request))
                .isInstanceOf(InvalidDateOfBirthException.class);

        verify(userRepository, never()).save(org.mockito.ArgumentMatchers.any(User.class));
    }
}
