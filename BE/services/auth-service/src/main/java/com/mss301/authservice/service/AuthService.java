package com.mss301.authservice.service;

import com.mss301.authservice.config.JwtProperties;
import com.mss301.authservice.config.PasswordResetProperties;
import com.mss301.authservice.config.VerificationProperties;
import com.mss301.authservice.dto.AccountResponse;
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
import com.mss301.authservice.entity.AccountRole;
import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.AuthProvider;
import com.mss301.authservice.entity.EmailVerification;
import com.mss301.authservice.entity.PasswordResetToken;
import com.mss301.authservice.entity.RefreshToken;
import com.mss301.authservice.entity.UserAccount;
import com.mss301.authservice.exception.AuthException;
import com.mss301.authservice.exception.ErrorCode;
import com.mss301.authservice.repository.EmailVerificationRepository;
import com.mss301.authservice.repository.PasswordResetTokenRepository;
import com.mss301.authservice.repository.RefreshTokenRepository;
import com.mss301.authservice.repository.UserAccountRepository;
import com.mss301.authservice.security.JwtService;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private static final String TOKEN_TYPE = "Bearer";

    private final UserAccountRepository userAccountRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final EmailVerificationRepository emailVerificationRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final JwtProperties jwtProperties;
    private final VerificationProperties verificationProperties;
    private final PasswordResetProperties passwordResetProperties;
    private final SecureTokenService secureTokenService;
    private final EmailService emailService;
    private final GoogleTokenVerifier googleTokenVerifier;

    public MessageResponse register(RegisterRequest request) {
        ensureEmailIsAvailable(request.email());

        UserAccount account = UserAccount.builder()
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .fullName(request.fullName())
                .role(AccountRole.USER)
                .status(AccountStatus.INACTIVE)
                .emailVerified(false)
                .provider(AuthProvider.LOCAL)
                .failedLoginAttempts(0)
                .build();

        UserAccount savedAccount = userAccountRepository.save(account);
        createAndSendVerificationOtp(savedAccount);

        return MessageResponse.builder()
                .message("Account registered successfully. Please verify your email before logging in.")
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        UserAccount account = userAccountRepository.findByEmailIgnoreCase(request.email())
                .orElseThrow(() -> new AuthException(
                        ErrorCode.INVALID_CREDENTIALS,
                        "Invalid email or password",
                        HttpStatus.UNAUTHORIZED));

        if (account.getProvider() != AuthProvider.LOCAL || account.getPasswordHash() == null) {
            throw new AuthException(
                    ErrorCode.INVALID_CREDENTIALS,
                    "Invalid email or password",
                    HttpStatus.UNAUTHORIZED);
        }

        if (!passwordEncoder.matches(request.password(), account.getPasswordHash())) {
            throw new AuthException(
                    ErrorCode.INVALID_CREDENTIALS,
                    "Invalid email or password",
                    HttpStatus.UNAUTHORIZED);
        }

        ensureAccountCanLogin(account);

        String accessToken = jwtService.generateAccessToken(account);
        CreatedRefreshToken refreshToken = createRefreshToken(account);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken.rawToken())
                .tokenType(TOKEN_TYPE)
                .expiresIn(jwtProperties.getAccessTokenExpirationMinutes() * 60)
                .account(toAccountResponse(account))
                .build();
    }

    public AuthResponse googleLogin(GoogleLoginRequest request) {
        GoogleTokenVerifier.GoogleAccountInfo googleAccount = googleTokenVerifier.verify(request.idToken());

        UserAccount account = userAccountRepository
                .findByProviderAndProviderId(AuthProvider.GOOGLE, googleAccount.providerId())
                .orElseGet(() -> findOrCreateGoogleAccount(googleAccount));

        ensureAccountCanLogin(account);

        CreatedRefreshToken refreshToken = createRefreshToken(account);
        return AuthResponse.builder()
                .accessToken(jwtService.generateAccessToken(account))
                .refreshToken(refreshToken.rawToken())
                .tokenType(TOKEN_TYPE)
                .expiresIn(jwtProperties.getAccessTokenExpirationMinutes() * 60)
                .account(toAccountResponse(account))
                .build();
    }

    public MessageResponse verifyEmail(VerifyEmailRequest request) {
        UserAccount account = findAccountByEmail(request.email());
        if (Boolean.TRUE.equals(account.getEmailVerified()) && account.getStatus() == AccountStatus.ACTIVE) {
            return MessageResponse.builder()
                    .message("Email is already verified.")
                    .build();
        }

        EmailVerification verification = emailVerificationRepository
                .findFirstByUserAccountAccountIdAndConsumedAtIsNullOrderByCreatedAtDesc(account.getAccountId())
                .orElseThrow(() -> new AuthException(
                        ErrorCode.INVALID_VERIFICATION_TOKEN,
                        "Verification OTP not found",
                        HttpStatus.BAD_REQUEST));

        if (LocalDateTime.now().isAfter(verification.getExpiresAt())) {
            throw new AuthException(
                    ErrorCode.VERIFICATION_TOKEN_EXPIRED,
                    "Verification OTP has expired",
                    HttpStatus.BAD_REQUEST);
        }

        if (!secureTokenService.matches(request.otp(), verification.getOtpHash())) {
            throw new AuthException(
                    ErrorCode.INVALID_VERIFICATION_TOKEN,
                    "Invalid verification OTP",
                    HttpStatus.BAD_REQUEST);
        }

        verification.setConsumedAt(LocalDateTime.now());
        account.setEmailVerified(true);
        account.setStatus(AccountStatus.ACTIVE);

        return MessageResponse.builder()
                .message("Email verified successfully. You can now log in.")
                .build();
    }

    public MessageResponse resendVerificationOtp(EmailRequest request) {
        UserAccount account = findAccountByEmail(request.email());
        if (Boolean.TRUE.equals(account.getEmailVerified()) && account.getStatus() == AccountStatus.ACTIVE) {
            return MessageResponse.builder()
                    .message("Email is already verified.")
                    .build();
        }

        createAndSendVerificationOtp(account);

        return MessageResponse.builder()
                .message("Verification OTP has been sent.")
                .build();
    }

    public AuthResponse refresh(RefreshTokenRequest request) {
        RefreshToken currentToken = findValidRefreshToken(request.refreshToken());
        UserAccount account = currentToken.getUserAccount();
        ensureAccountCanLogin(account);

        currentToken.setRevokedAt(LocalDateTime.now());
        CreatedRefreshToken newRefreshToken = createRefreshToken(account);
        currentToken.setReplacedByTokenId(newRefreshToken.entity().getRefreshTokenId());

        return AuthResponse.builder()
                .accessToken(jwtService.generateAccessToken(account))
                .refreshToken(newRefreshToken.rawToken())
                .tokenType(TOKEN_TYPE)
                .expiresIn(jwtProperties.getAccessTokenExpirationMinutes() * 60)
                .account(toAccountResponse(account))
                .build();
    }

    public MessageResponse logout(LogoutRequest request) {
        RefreshToken refreshToken = findValidRefreshToken(request.refreshToken());
        refreshToken.setRevokedAt(LocalDateTime.now());

        return MessageResponse.builder()
                .message("Logged out successfully.")
                .build();
    }

    public MessageResponse forgotPassword(EmailRequest request) {
        userAccountRepository.findByEmailIgnoreCase(request.email())
                .filter(account -> account.getProvider() == AuthProvider.LOCAL)
                .filter(account -> account.getPasswordHash() != null)
                .ifPresent(this::createAndSendPasswordResetToken);

        return MessageResponse.builder()
                .message("If the email exists, password reset instructions have been sent.")
                .build();
    }

    public MessageResponse resetPassword(ResetPasswordRequest request) {
        String tokenHash = secureTokenService.hashTokenSha256(request.resetToken());
        PasswordResetToken resetToken = passwordResetTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new AuthException(
                        ErrorCode.INVALID_RESET_TOKEN,
                        "Invalid password reset token",
                        HttpStatus.BAD_REQUEST));

        if (resetToken.getConsumedAt() != null) {
            throw new AuthException(
                    ErrorCode.RESET_TOKEN_ALREADY_USED,
                    "Password reset token has already been used",
                    HttpStatus.BAD_REQUEST);
        }
        if (LocalDateTime.now().isAfter(resetToken.getExpiresAt())) {
            resetToken.setConsumedAt(LocalDateTime.now());
            throw new AuthException(
                    ErrorCode.RESET_TOKEN_EXPIRED,
                    "Password reset token has expired",
                    HttpStatus.BAD_REQUEST);
        }

        UserAccount account = resetToken.getUserAccount();
        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        resetToken.setConsumedAt(LocalDateTime.now());
        revokeActiveRefreshTokens(account);

        return MessageResponse.builder()
                .message("Password has been reset successfully. Please log in with your new password.")
                .build();
    }

    public MessageResponse changePassword(Long accountId, ChangePasswordRequest request) {
        UserAccount account = findAccountById(accountId);
        ensureAccountCanLogin(account);

        if (account.getProvider() != AuthProvider.LOCAL || account.getPasswordHash() == null) {
            throw new AuthException(
                    ErrorCode.PASSWORD_CHANGE_UNAVAILABLE,
                    "Password change is not available for this account",
                    HttpStatus.BAD_REQUEST);
        }
        if (!passwordEncoder.matches(request.currentPassword(), account.getPasswordHash())) {
            throw new AuthException(
                    ErrorCode.INVALID_CURRENT_PASSWORD,
                    "Current password is incorrect",
                    HttpStatus.BAD_REQUEST);
        }
        if (!request.newPassword().equals(request.confirmPassword())) {
            throw new AuthException(
                    ErrorCode.PASSWORD_MISMATCH,
                    "New password and confirm password do not match",
                    HttpStatus.BAD_REQUEST);
        }
        if (passwordEncoder.matches(request.newPassword(), account.getPasswordHash())) {
            throw new AuthException(
                    ErrorCode.PASSWORD_REUSE_NOT_ALLOWED,
                    "New password must be different from current password",
                    HttpStatus.BAD_REQUEST);
        }

        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        revokeActiveRefreshTokens(account);

        return MessageResponse.builder()
                .message("Password changed successfully. Please log in again.")
                .build();
    }

    @Transactional(readOnly = true)
    public AccountResponse getCurrentAccount(Long accountId) {
        UserAccount account = findAccountById(accountId);
        ensureAccountCanAccessSession(account);
        return toAccountResponse(account);
    }

    private CreatedRefreshToken createRefreshToken(UserAccount account) {
        String rawToken = secureTokenService.generateToken();
        RefreshToken refreshToken = RefreshToken.builder()
                .userAccount(account)
                .tokenHash(secureTokenService.hashToken(rawToken))
                .expiresAt(LocalDateTime.now().plusDays(jwtProperties.getRefreshTokenExpirationDays()))
                .build();
        RefreshToken savedToken = refreshTokenRepository.save(refreshToken);
        return new CreatedRefreshToken(rawToken, savedToken);
    }

    private UserAccount findOrCreateGoogleAccount(GoogleTokenVerifier.GoogleAccountInfo googleAccount) {
        return userAccountRepository.findByEmailIgnoreCase(googleAccount.email())
                .map(existingAccount -> {
                    if (existingAccount.getProvider() != AuthProvider.GOOGLE) {
                        throw new AuthException(
                                ErrorCode.AUTH_PROVIDER_MISMATCH,
                                "This email is already registered with email and password. Please sign in using your password.",
                                HttpStatus.CONFLICT);
                    }
                    existingAccount.setProviderId(googleAccount.providerId());
                    return existingAccount;
                })
                .orElseGet(() -> userAccountRepository.save(UserAccount.builder()
                        .email(googleAccount.email())
                        .fullName(googleAccount.fullName())
                        .role(AccountRole.USER)
                        .status(AccountStatus.ACTIVE)
                        .emailVerified(true)
                        .provider(AuthProvider.GOOGLE)
                        .providerId(googleAccount.providerId())
                        .failedLoginAttempts(0)
                        .build()));
    }

    private void createAndSendPasswordResetToken(UserAccount account) {
        String rawToken = secureTokenService.generateToken();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .userAccount(account)
                .tokenHash(secureTokenService.hashTokenSha256(rawToken))
                .expiresAt(LocalDateTime.now().plusMinutes(passwordResetProperties.getTokenExpirationMinutes()))
                .build();
        passwordResetTokenRepository.save(resetToken);
        emailService.sendPasswordResetToken(account.getEmail(), rawToken);
    }

    private void ensureEmailIsAvailable(String email) {
        if (userAccountRepository.existsByEmailIgnoreCase(email)) {
            throw new AuthException(
                    ErrorCode.EMAIL_ALREADY_EXISTS,
                    "Email already exists",
                    HttpStatus.CONFLICT);
        }
    }

    private UserAccount findAccountByEmail(String email) {
        return userAccountRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new AuthException(
                        ErrorCode.ACCOUNT_NOT_FOUND,
                        "Account not found",
                        HttpStatus.NOT_FOUND));
    }

    private UserAccount findAccountById(Long accountId) {
        return userAccountRepository.findById(accountId)
                .orElseThrow(() -> new AuthException(
                        ErrorCode.ACCOUNT_NOT_FOUND,
                        "Account not found",
                        HttpStatus.NOT_FOUND));
    }

    private void createAndSendVerificationOtp(UserAccount account) {
        String otp = secureTokenService.generateOtp();
        int nextSentCount = emailVerificationRepository
                .findFirstByUserAccountAccountIdOrderByCreatedAtDesc(account.getAccountId())
                .map(verification -> verification.getSentCount() + 1)
                .orElse(1);

        EmailVerification verification = EmailVerification.builder()
                .userAccount(account)
                .otpHash(secureTokenService.hashToken(otp))
                .expiresAt(LocalDateTime.now().plusMinutes(verificationProperties.getOtpExpirationMinutes()))
                .sentCount(nextSentCount)
                .lastSentAt(LocalDateTime.now())
                .build();
        emailVerificationRepository.save(verification);
        emailService.sendVerificationOtp(account.getEmail(), otp);
    }

    private RefreshToken findValidRefreshToken(String rawToken) {
        RefreshToken refreshToken = refreshTokenRepository.findByRevokedAtIsNull().stream()
                .filter(token -> secureTokenService.matches(rawToken, token.getTokenHash()))
                .findFirst()
                .orElseThrow(() -> new AuthException(
                        ErrorCode.INVALID_REFRESH_TOKEN,
                        "Invalid refresh token",
                        HttpStatus.UNAUTHORIZED));

        if (LocalDateTime.now().isAfter(refreshToken.getExpiresAt())) {
            refreshToken.setRevokedAt(LocalDateTime.now());
            throw new AuthException(
                    ErrorCode.REFRESH_TOKEN_EXPIRED,
                    "Refresh token has expired",
                    HttpStatus.UNAUTHORIZED);
        }

        return refreshToken;
    }

    private void revokeActiveRefreshTokens(UserAccount account) {
        LocalDateTime revokedAt = LocalDateTime.now();
        refreshTokenRepository.findByUserAccountAccountIdAndRevokedAtIsNull(account.getAccountId())
                .forEach(refreshToken -> refreshToken.setRevokedAt(revokedAt));
    }

    private void ensureAccountCanLogin(UserAccount account) {
        if (account.getStatus() == AccountStatus.LOCKED) {
            throw new AuthException(
                    ErrorCode.ACCOUNT_LOCKED,
                    "Account is locked",
                    HttpStatus.FORBIDDEN);
        }
        if (account.getStatus() != AccountStatus.ACTIVE || !Boolean.TRUE.equals(account.getEmailVerified())) {
            throw new AuthException(
                    ErrorCode.EMAIL_NOT_VERIFIED,
                    "Please verify your email before logging in",
                    HttpStatus.FORBIDDEN);
        }
    }

    private void ensureAccountCanAccessSession(UserAccount account) {
        if (account.getStatus() != AccountStatus.ACTIVE) {
            throw new AuthException(
                    ErrorCode.ACCOUNT_DISABLED,
                    "Your account is not active.",
                    HttpStatus.FORBIDDEN);
        }
        if (!Boolean.TRUE.equals(account.getEmailVerified())) {
            throw new AuthException(
                    ErrorCode.EMAIL_NOT_VERIFIED,
                    "Please verify your email before continuing.",
                    HttpStatus.FORBIDDEN);
        }
    }

    private AccountResponse toAccountResponse(UserAccount account) {
        return AccountResponse.builder()
                .accountId(account.getAccountId())
                .email(account.getEmail())
                .fullName(account.getFullName())
                .role(account.getRole())
                .status(account.getStatus())
                .emailVerified(account.getEmailVerified())
                .provider(account.getProvider())
                .createdAt(account.getCreatedAt())
                .updatedAt(account.getUpdatedAt())
                .build();
    }

    private record CreatedRefreshToken(String rawToken, RefreshToken entity) {
    }
}
