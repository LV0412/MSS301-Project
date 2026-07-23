package com.mss301.authservice.service;

import com.mss301.authservice.dto.AccountResponse;
import com.mss301.authservice.dto.AdminCreateAccountRequest;
import com.mss301.authservice.dto.AuthResponse;
import com.mss301.authservice.dto.ChangePasswordRequest;
import com.mss301.authservice.dto.EmailRequest;
import com.mss301.authservice.dto.GoogleLoginRequest;
import com.mss301.authservice.dto.LoginRequest;
import com.mss301.authservice.dto.LogoutRequest;
import com.mss301.authservice.dto.MessageResponse;
import com.mss301.authservice.dto.RefreshTokenRequest;
import com.mss301.authservice.dto.RegisterRequest;
import com.mss301.authservice.dto.ResetPasswordRequest;
import com.mss301.authservice.dto.VerifyEmailRequest;

public interface AuthService {

    MessageResponse register(RegisterRequest request);

    AccountResponse createAccountByAdmin(AdminCreateAccountRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse googleLogin(GoogleLoginRequest request);

    AuthResponse refresh(RefreshTokenRequest request);

    MessageResponse logout(LogoutRequest request);

    MessageResponse verifyEmail(VerifyEmailRequest request);

    MessageResponse resendVerificationOtp(EmailRequest request);

    MessageResponse forgotPassword(EmailRequest request);

    MessageResponse resetPassword(ResetPasswordRequest request);

    MessageResponse changePassword(Long accountId, ChangePasswordRequest request);

    AccountResponse getCurrentAccount(Long accountId, Long userId);
}
