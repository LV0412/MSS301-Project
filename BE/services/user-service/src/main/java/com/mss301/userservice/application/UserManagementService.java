package com.mss301.userservice.application;

import com.mss301.userservice.api.dto.CreateUserRequest;
import com.mss301.userservice.api.dto.UpdateUserRequest;
import com.mss301.userservice.api.dto.UserResponse;
import com.mss301.userservice.domain.User;
import com.mss301.userservice.exception.DuplicateEmailException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.infrastructure.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional
public class UserManagementService {

    private final UserRepository userRepository;

    public UserResponse createUser(CreateUserRequest request) {
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

    @Transactional(readOnly = true)
    public UserResponse getUserById(Long userId) {
        return toResponse(findUser(userId));
    }

    @Transactional(readOnly = true)
    public Page<UserResponse> getAllUsers(Pageable pageable) {
        return userRepository.findAll(pageable).map(this::toResponse);
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

    private UserResponse toResponse(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .dob(user.getDob())
                .gender(user.getGender())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
