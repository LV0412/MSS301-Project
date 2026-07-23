package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateUserRequest;
import com.mss301.userservice.dto.UpdateUserRequest;
import com.mss301.userservice.dto.UserResponse;
import com.mss301.userservice.dto.internal.InternalUserProvisionRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface UserManagementService {

    UserResponse createUser(CreateUserRequest request);

    UserResponse provisionFromAuth(InternalUserProvisionRequest request);

    UserResponse getUserById(Long userId);

    Page<UserResponse> getAllUsers(Pageable pageable);

    UserResponse updateUser(Long userId, UpdateUserRequest request);

    void deleteUser(Long userId);
}
