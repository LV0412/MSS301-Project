package com.mss301.authservice.controller;

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
import com.mss301.authservice.security.AuthUserPrincipal;
import com.mss301.authservice.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Authentication, token, email verification, password recovery, and account session APIs")
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "Register account", description = "Create an inactive LOCAL account and send an email verification OTP.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Account registered"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "409", description = "Email already exists")
    })
    @PostMapping("/register")
    public ResponseEntity<MessageResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @Operation(summary = "Create user account as admin", description = "Create an inactive LOCAL account with the server-configured temporary password, provision its User Service profile, and send a verification OTP.")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Account and user profile created"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Authentication required"),
            @ApiResponse(responseCode = "403", description = "Admin role required"),
            @ApiResponse(responseCode = "409", description = "Email already exists")
    })
    @PostMapping("/admin/accounts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AccountResponse> createAccountByAdmin(
            @Valid @RequestBody AdminCreateAccountRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.createAccountByAdmin(request));
    }

    @Operation(summary = "Login with email and password", description = "Authenticate a verified LOCAL account and return access and refresh tokens.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Login successful"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Invalid credentials"),
            @ApiResponse(responseCode = "403", description = "Account locked, disabled, or email not verified")
    })
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @Operation(summary = "Login with Google", description = "Verify a Google ID token, create or find a GOOGLE account, and return access and refresh tokens.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Google login successful"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Invalid Google ID token"),
            @ApiResponse(responseCode = "409", description = "Email is already registered with another provider"),
            @ApiResponse(responseCode = "503", description = "Google authentication is not configured")
    })
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(authService.googleLogin(request));
    }

    @Operation(summary = "Refresh token", description = "Rotate a valid refresh token and return a new access token and refresh token.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Token refreshed"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Invalid or expired refresh token"),
            @ApiResponse(responseCode = "403", description = "Account cannot access the session")
    })
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refresh(request));
    }

    @Operation(summary = "Logout", description = "Revoke the supplied refresh token. Requires a valid access token.")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Logged out"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "401", description = "Missing/invalid access token or refresh token")
    })
    @PostMapping("/logout")
    public ResponseEntity<MessageResponse> logout(@Valid @RequestBody LogoutRequest request) {
        return ResponseEntity.ok(authService.logout(request));
    }

    @Operation(summary = "Verify email", description = "Activate an account by verifying the latest email OTP.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Email verified"),
            @ApiResponse(responseCode = "400", description = "Invalid or expired OTP"),
            @ApiResponse(responseCode = "404", description = "Account not found")
    })
    @PostMapping("/verify-email")
    public ResponseEntity<MessageResponse> verifyEmail(@Valid @RequestBody VerifyEmailRequest request) {
        return ResponseEntity.ok(authService.verifyEmail(request));
    }

    @Operation(summary = "Resend verification OTP", description = "Send a new email verification OTP to an unverified account.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "OTP sent or account already verified"),
            @ApiResponse(responseCode = "400", description = "Invalid request"),
            @ApiResponse(responseCode = "404", description = "Account not found")
    })
    @PostMapping("/resend-otp")
    public ResponseEntity<MessageResponse> resendOtp(@Valid @RequestBody EmailRequest request) {
        return ResponseEntity.ok(authService.resendVerificationOtp(request));
    }

    @Operation(summary = "Forgot password", description = "Request a password reset token. Always returns the same response to avoid email enumeration.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Password reset instructions response returned"),
            @ApiResponse(responseCode = "400", description = "Invalid request")
    })
    @PostMapping("/forgot-password")
    public ResponseEntity<MessageResponse> forgotPassword(@Valid @RequestBody EmailRequest request) {
        return ResponseEntity.ok(authService.forgotPassword(request));
    }

    @Operation(summary = "Reset password", description = "Reset a LOCAL account password with a valid password reset token.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Password reset"),
            @ApiResponse(responseCode = "400", description = "Invalid, used, or expired reset token")
    })
    @PostMapping("/reset-password")
    public ResponseEntity<MessageResponse> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        return ResponseEntity.ok(authService.resetPassword(request));
    }

    @Operation(summary = "Change password", description = "Change the current user's LOCAL account password and revoke active refresh tokens.")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Password changed"),
            @ApiResponse(responseCode = "400", description = "Invalid current password, password mismatch, or password reuse"),
            @ApiResponse(responseCode = "401", description = "Missing or invalid access token"),
            @ApiResponse(responseCode = "403", description = "Account cannot access the session")
    })
    @PostMapping("/change-password")
    public ResponseEntity<MessageResponse> changePassword(
            @AuthenticationPrincipal AuthUserPrincipal principal,
            @Valid @RequestBody ChangePasswordRequest request) {
        return ResponseEntity.ok(authService.changePassword(principal.getAccountId(), request));
    }

    @Operation(summary = "Get current account", description = "Return the current authenticated account from the access token.")
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Current account returned"),
            @ApiResponse(responseCode = "401", description = "Missing or invalid access token"),
            @ApiResponse(responseCode = "403", description = "Account disabled or email not verified"),
            @ApiResponse(responseCode = "404", description = "Account not found")
    })
    @GetMapping("/me")
    public ResponseEntity<AccountResponse> me(@AuthenticationPrincipal AuthUserPrincipal principal) {
        return ResponseEntity.ok(authService.getCurrentAccount(principal.getAccountId(), principal.getUserId()));
    }
}
