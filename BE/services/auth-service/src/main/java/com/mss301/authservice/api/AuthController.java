package com.mss301.authservice.api;

import com.mss301.authservice.api.dto.AccountResponse;
import com.mss301.authservice.api.dto.AuthResponse;
import com.mss301.authservice.api.dto.ChangePasswordRequest;
import com.mss301.authservice.api.dto.EmailRequest;
import com.mss301.authservice.api.dto.GoogleLoginRequest;
import com.mss301.authservice.api.dto.LoginRequest;
import com.mss301.authservice.api.dto.LogoutRequest;
import com.mss301.authservice.api.dto.MessageResponse;
import com.mss301.authservice.api.dto.RefreshTokenRequest;
import com.mss301.authservice.api.dto.RegisterRequest;
import com.mss301.authservice.api.dto.ResetPasswordRequest;
import com.mss301.authservice.api.dto.VerifyEmailRequest;
import com.mss301.authservice.application.AuthService;
import com.mss301.authservice.security.AuthUserPrincipal;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest servletRequest) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request, servletRequest));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest) {
        return ResponseEntity.ok(authService.login(request, servletRequest));
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(
            @Valid @RequestBody GoogleLoginRequest request,
            HttpServletRequest servletRequest) {
        return ResponseEntity.ok(authService.googleLogin(request, servletRequest));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(
            @Valid @RequestBody RefreshTokenRequest request,
            HttpServletRequest servletRequest) {
        return ResponseEntity.ok(authService.refresh(request, servletRequest));
    }

    @PostMapping("/logout")
    public ResponseEntity<MessageResponse> logout(@Valid @RequestBody LogoutRequest request) {
        authService.logout(request);
        return ResponseEntity.ok(MessageResponse.builder().message("Logged out").build());
    }

    @PostMapping("/change-password")
    public ResponseEntity<MessageResponse> changePassword(
            @AuthenticationPrincipal AuthUserPrincipal principal,
            @Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(principal.getAccountId(), request);
        return ResponseEntity.ok(MessageResponse.builder().message("Password changed").build());
    }

    @PostMapping("/verify-email")
    public ResponseEntity<AccountResponse> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        return ResponseEntity.ok(authService.verifyEmail(request));
    }

    @PostMapping("/resend-otp")
    public ResponseEntity<MessageResponse> resendOtp(@Valid @RequestBody EmailRequest request) {
        authService.resendVerificationOtp(request);
        return ResponseEntity.ok(MessageResponse.builder().message("Verification OTP sent").build());
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<MessageResponse> forgotPassword(@Valid @RequestBody EmailRequest request) {
        authService.forgotPassword(request);
        return ResponseEntity.ok(MessageResponse.builder().message("If the email exists, a reset token was sent").build());
    }

    @PostMapping("/reset-password")
    public ResponseEntity<MessageResponse> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok(MessageResponse.builder().message("Password reset").build());
    }

    @GetMapping("/me")
    public ResponseEntity<AccountResponse> me(@AuthenticationPrincipal AuthUserPrincipal principal) {
        return ResponseEntity.ok(authService.me(principal.getAccountId()));
    }
}
