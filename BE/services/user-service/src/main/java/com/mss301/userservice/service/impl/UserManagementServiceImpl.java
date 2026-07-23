package com.mss301.userservice.service.impl;

import com.mss301.userservice.dto.CreateUserRequest;
import com.mss301.userservice.dto.UpdateUserRequest;
import com.mss301.userservice.dto.UserResponse;
import com.mss301.userservice.dto.internal.InternalUserProvisionRequest;
import com.mss301.userservice.entity.Gender;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.DuplicateEmailException;
import com.mss301.userservice.exception.InvalidDateOfBirthException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.service.UserManagementService;
import com.mss301.userservice.util.PageableUtils;
import java.time.LocalDate;
import java.time.Period;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional
public class UserManagementServiceImpl implements UserManagementService {

    private static final int MIN_AGE = 13;
    private static final int MAX_AGE = 120;

    private final UserRepository userRepository;

    public UserResponse createUser(CreateUserRequest request) {
        validateDateOfBirth(request.dob());
        ensureEmailIsAvailable(request.email());

        User user = User.builder()
                .email(request.email())
                .passwordHash(request.passwordHash())
                .fullName(request.fullName())
                .dob(request.dob())
                .gender(request.gender())
                .build();

        return toResponse(userRepository.save(user));
    }

    public UserResponse provisionFromAuth(InternalUserProvisionRequest request) {
        User user = userRepository.findByAuthAccountId(request.authAccountId())
                .orElseGet(() -> userRepository.findByEmailIgnoreCase(request.email())
                        .map(existing -> {
                            existing.setAuthAccountId(request.authAccountId());
                            return existing;
                        })
                        .orElseGet(() -> User.builder()
                                .authAccountId(request.authAccountId())
                                .email(request.email())
                                .passwordHash("managed-by-auth-service")
                                .fullName(request.fullName())
                                .gender(Gender.OTHER)
                                .build()));

        return toResponse(userRepository.save(user));
    }

    @Transactional(readOnly = true)
    public UserResponse getUserById(Long userId) {
        return toResponse(findUser(userId));
    }

    @Transactional(readOnly = true)
    public Page<UserResponse> getAllUsers(Pageable pageable) {
        Pageable normalizedPageable = PageableUtils.normalizeSort(pageable, "createdAt");
        Page<User> users = userRepository.findAll(normalizedPageable);
        return users.map(this::toResponse);
    }

    public UserResponse updateUser(Long userId, UpdateUserRequest request) {
        User user = findUser(userId);

        if (StringUtils.hasText(request.email()) && !request.email().equalsIgnoreCase(user.getEmail())) {
            ensureEmailIsAvailable(request.email());
            user.setEmail(request.email());
        }
        if (StringUtils.hasText(request.passwordHash())) {
            user.setPasswordHash(request.passwordHash());
        }
        if (StringUtils.hasText(request.fullName())) {
            user.setFullName(request.fullName());
        }
        if (request.dob() != null) {
            validateDateOfBirth(request.dob());
            user.setDob(request.dob());
        }
        if (request.gender() != null) {
            user.setGender(request.gender());
        }

        return toResponse(userRepository.save(user));
    }

    public void deleteUser(Long userId) {
        User user = findUser(userId);
        userRepository.delete(user);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private void ensureEmailIsAvailable(String email) {
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new DuplicateEmailException(email);
        }
    }

    private void validateDateOfBirth(LocalDate dob) {
        if (dob == null) {
            return;
        }

        int age = Period.between(dob, LocalDate.now()).getYears();
        if (age < MIN_AGE || age > MAX_AGE) {
            throw new InvalidDateOfBirthException(MIN_AGE, MAX_AGE);
        }
    }

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .authAccountId(user.getAuthAccountId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .dob(user.getDob())
                .gender(user.getGender())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
