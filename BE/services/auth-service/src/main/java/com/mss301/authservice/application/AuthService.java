package com.mss301.authservice.application;

import com.mss301.authservice.api.dto.AccountResponse;
import com.mss301.authservice.api.dto.AuthResponse;
import com.mss301.authservice.api.dto.ChangePasswordRequest;
import com.mss301.authservice.api.dto.EmailRequest;
import com.mss301.authservice.api.dto.GoogleLoginRequest;
import com.mss301.authservice.api.dto.LoginRequest;
import com.mss301.authservice.api.dto.LogoutRequest;
import com.mss301.authservice.api.dto.RefreshTokenRequest;
import com.mss301.authservice.api.dto.RegisterRequest;
import com.mss301.authservice.api.dto.ResetPasswordRequest;
import com.mss301.authservice.api.dto.VerifyEmailRequest;
import com.mss301.authservice.config.AuthProperties;
import com.mss301.authservice.domain.AccountRole;
import com.mss301.authservice.domain.AccountStatus;
import com.mss301.authservice.domain.AuthProvider;
import com.mss301.authservice.domain.EmailVerification;
import com.mss301.authservice.domain.PasswordResetToken;
import com.mss301.authservice.domain.RefreshToken;
import com.mss301.authservice.domain.UserAccount;
import com.mss301.authservice.exception.AuthException;
import com.mss301.authservice.infrastructure.repositories.EmailVerificationRepository;
import com.mss301.authservice.infrastructure.repositories.PasswordResetTokenRepository;
import com.mss301.authservice.infrastructure.repositories.RefreshTokenRepository;
import com.mss301.authservice.infrastructure.repositories.UserAccountRepository;
import com.mss301.authservice.security.JwtService;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    private final UserAccountRepository userAccountRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final EmailVerificationRepository emailVerificationRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final SecureTokenService secureTokenService;
    private final EmailService emailService;
    private final GoogleTokenVerifier googleTokenVerifier;
    private final AuthProperties authProperties;

    public AuthResponse register(RegisterRequest request, HttpServletRequest servletRequest) {
        String email = normalizeEmail(request.email());
        if (userAccountRepository.existsByEmailIgnoreCase(email)) {
            throw new AuthException(HttpStatus.CONFLICT, "Email already exists");
        }

        UserAccount account = UserAccount.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(request.password()))
                .provider(AuthProvider.LOCAL)
                .role(AccountRole.USER)
                .status(AccountStatus.INACTIVE)
                .emailVerified(false)
                .failedLoginAttempts(0)
                .build();

        account = userAccountRepository.save(account);
        createAndSendVerification(account);
        return issueTokenPair(account, request.deviceInfo(), servletRequest);
    }

    public AuthResponse login(LoginRequest request, HttpServletRequest servletRequest) {
        UserAccount account = findAccountByEmail(request.email());
        ensureLoginAllowed(account);

        if (!StringUtils.hasText(account.getPasswordHash())
                || !passwordEncoder.matches(request.password(), account.getPasswordHash())) {
            recordFailedLogin(account);
            throw new BadCredentialsException("Invalid email or password");
        }

        account.setFailedLoginAttempts(0);
        account.setLockedUntil(null);
        account.setLastLoginAt(LocalDateTime.now());
        userAccountRepository.save(account);

        return issueTokenPair(account, request.deviceInfo(), servletRequest);
    }

    public AuthResponse googleLogin(GoogleLoginRequest request, HttpServletRequest servletRequest) {
        GoogleTokenVerifier.GoogleAccount googleAccount = googleTokenVerifier.verify(request.idToken());

        UserAccount account = userAccountRepository
                .findByProviderAndProviderId(AuthProvider.GOOGLE, googleAccount.providerId())
                .orElseGet(() -> createGoogleAccount(googleAccount));

        ensureAccountNotBanned(account);
        account.setLastLoginAt(LocalDateTime.now());
        userAccountRepository.save(account);

        return issueTokenPair(account, request.deviceInfo(), servletRequest);
    }

    public AuthResponse refresh(RefreshTokenRequest request, HttpServletRequest servletRequest) {
        RefreshToken currentToken = findValidRefreshToken(request.refreshToken());
        UserAccount account = currentToken.getUserAccount();
        ensureAccountNotBanned(account);

        currentToken.setRevoked(true);
        currentToken.setRevokedAt(LocalDateTime.now());
        refreshTokenRepository.save(currentToken);

        AuthResponse response = issueTokenPair(account, request.deviceInfo(), servletRequest);
        refreshTokenRepository.findByTokenHash(secureTokenService.sha256(response.refreshToken()))
                .ifPresent(newToken -> {
                    currentToken.setReplacedByTokenId(newToken.getId());
                    refreshTokenRepository.save(currentToken);
                });
        return response;
    }

    public void logout(LogoutRequest request) {
        refreshTokenRepository.findByTokenHash(secureTokenService.sha256(request.refreshToken()))
                .ifPresent(token -> {
                    token.setRevoked(true);
                    token.setRevokedAt(LocalDateTime.now());
                    refreshTokenRepository.save(token);
                });
    }

    public void changePassword(Long accountId, ChangePasswordRequest request) {
        UserAccount account = findAccountById(accountId);
        if (!StringUtils.hasText(account.getPasswordHash())
                || !passwordEncoder.matches(request.currentPassword(), account.getPasswordHash())) {
            throw new BadCredentialsException("Invalid current password");
        }

        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        userAccountRepository.save(account);
        revokeAllRefreshTokens(account.getId());
    }

    public AccountResponse verifyEmail(VerifyEmailRequest request) {
        UserAccount account = findAccountByEmail(request.email());
        if (account.isEmailVerified()) {
            return toAccountResponse(account);
        }

        EmailVerification verification = emailVerificationRepository
                .findTopByUserAccountIdAndVerifiedFalseOrderByCreatedAtDesc(account.getId())
                .orElseThrow(() -> new AuthException(HttpStatus.BAD_REQUEST, "Verification code not found"));

        if (verification.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new AuthException(HttpStatus.BAD_REQUEST, "Verification code expired");
        }
        if (verification.getAttemptCount() >= 5) {
            throw new AuthException(HttpStatus.TOO_MANY_REQUESTS, "Too many verification attempts");
        }
        if (!secureTokenService.sha256(request.otpCode()).equals(verification.getOtpHash())) {
            verification.setAttemptCount(verification.getAttemptCount() + 1);
            emailVerificationRepository.save(verification);
            throw new AuthException(HttpStatus.BAD_REQUEST, "Invalid verification code");
        }

        verification.setVerified(true);
        verification.setConsumedAt(LocalDateTime.now());
        emailVerificationRepository.save(verification);

        account.setEmailVerified(true);
        account.setStatus(AccountStatus.ACTIVE);
        return toAccountResponse(userAccountRepository.save(account));
    }

    public void resendVerificationOtp(EmailRequest request) {
        UserAccount account = findAccountByEmail(request.email());
        if (account.isEmailVerified()) {
            return;
        }

        emailVerificationRepository.findTopByUserAccountIdAndVerifiedFalseOrderByCreatedAtDesc(account.getId())
                .filter(existing -> existing.getLastSentAt().plusSeconds(
                                authProperties.security().resendOtpCooldownSeconds())
                        .isAfter(LocalDateTime.now()))
                .ifPresent(existing -> {
                    throw new AuthException(HttpStatus.TOO_MANY_REQUESTS, "Please wait before requesting another OTP");
                });

        createAndSendVerification(account);
    }

    public void forgotPassword(EmailRequest request) {
        userAccountRepository.findByEmailIgnoreCase(normalizeEmail(request.email()))
                .ifPresent(account -> {
                    LocalDateTime oneMinuteAgo = LocalDateTime.now().minusMinutes(1);
                    if (passwordResetTokenRepository.countByUserAccountIdAndCreatedAtAfter(
                            account.getId(),
                            oneMinuteAgo) >= 2) {
                        throw new AuthException(HttpStatus.TOO_MANY_REQUESTS, "Too many reset requests");
                    }

                    String rawToken = secureTokenService.generateOpaqueToken();
                    PasswordResetToken resetToken = PasswordResetToken.builder()
                            .userAccount(account)
                            .tokenHash(secureTokenService.sha256(rawToken))
                            .expiresAt(LocalDateTime.now().plusMinutes(
                                    authProperties.security().resetTokenExpiryMinutes()))
                            .used(false)
                            .build();
                    passwordResetTokenRepository.save(resetToken);
                    emailService.sendPasswordResetToken(account.getEmail(), rawToken);
                });
    }

    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository
                .findByTokenHash(secureTokenService.sha256(request.resetToken()))
                .orElseThrow(() -> new AuthException(HttpStatus.BAD_REQUEST, "Invalid reset token"));

        if (resetToken.isUsed()) {
            throw new AuthException(HttpStatus.BAD_REQUEST, "Reset token already used");
        }
        if (resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new AuthException(HttpStatus.BAD_REQUEST, "Reset token expired");
        }

        resetToken.setUsed(true);
        resetToken.setUsedAt(LocalDateTime.now());
        passwordResetTokenRepository.save(resetToken);

        UserAccount account = resetToken.getUserAccount();
        account.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        account.setFailedLoginAttempts(0);
        account.setLockedUntil(null);
        if (account.isEmailVerified() && account.getStatus() == AccountStatus.INACTIVE) {
            account.setStatus(AccountStatus.ACTIVE);
        }
        userAccountRepository.save(account);
        revokeAllRefreshTokens(account.getId());
    }

    @Transactional(readOnly = true)
    public AccountResponse me(Long accountId) {
        return toAccountResponse(findAccountById(accountId));
    }

    private UserAccount createGoogleAccount(GoogleTokenVerifier.GoogleAccount googleAccount) {
        userAccountRepository.findByEmailIgnoreCase(googleAccount.email())
                .ifPresent(existing -> {
                    throw new AuthException(HttpStatus.CONFLICT, "Email already registered with another provider");
                });

        UserAccount account = UserAccount.builder()
                .email(normalizeEmail(googleAccount.email()))
                .provider(AuthProvider.GOOGLE)
                .providerId(googleAccount.providerId())
                .role(AccountRole.USER)
                .status(AccountStatus.ACTIVE)
                .emailVerified(true)
                .failedLoginAttempts(0)
                .lastLoginAt(LocalDateTime.now())
                .build();
        return userAccountRepository.save(account);
    }

    private AuthResponse issueTokenPair(
            UserAccount account,
            String deviceInfo,
            HttpServletRequest servletRequest) {
        String accessToken = jwtService.generateAccessToken(account);
        String rawRefreshToken = secureTokenService.generateOpaqueToken();

        RefreshToken refreshToken = RefreshToken.builder()
                .userAccount(account)
                .tokenHash(secureTokenService.sha256(rawRefreshToken))
                .expiresAt(LocalDateTime.now().plusDays(authProperties.jwt().refreshTokenDays()))
                .revoked(false)
                .deviceInfo(deviceInfo)
                .ipAddress(resolveClientIp(servletRequest))
                .userAgent(servletRequest.getHeader("User-Agent"))
                .build();
        refreshTokenRepository.save(refreshToken);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(rawRefreshToken)
                .tokenType("Bearer")
                .expiresInSeconds(jwtService.accessTokenExpiresInSeconds())
                .account(toAccountResponse(account))
                .build();
    }

    private RefreshToken findValidRefreshToken(String rawRefreshToken) {
        RefreshToken refreshToken = refreshTokenRepository.findByTokenHash(secureTokenService.sha256(rawRefreshToken))
                .orElseThrow(() -> new AuthException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"));

        if (refreshToken.isRevoked()) {
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Refresh token revoked");
        }
        if (refreshToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Refresh token expired");
        }
        return refreshToken;
    }

    private void createAndSendVerification(UserAccount account) {
        String otpCode = secureTokenService.generateOtpCode();
        EmailVerification verification = EmailVerification.builder()
                .userAccount(account)
                .otpHash(secureTokenService.sha256(otpCode))
                .expiresAt(LocalDateTime.now().plusMinutes(authProperties.security().otpExpiryMinutes()))
                .attemptCount(0)
                .verified(false)
                .sentCount(1)
                .lastSentAt(LocalDateTime.now())
                .build();
        emailVerificationRepository.save(verification);
        emailService.sendVerificationOtp(account.getEmail(), otpCode);
    }

    private void ensureLoginAllowed(UserAccount account) {
        ensureAccountNotBanned(account);

        if (account.getLockedUntil() != null && account.getLockedUntil().isAfter(LocalDateTime.now())) {
            throw new AuthException(HttpStatus.FORBIDDEN, "Account temporarily locked");
        }
        if (account.getStatus() == AccountStatus.LOCKED
                && (account.getLockedUntil() == null || account.getLockedUntil().isAfter(LocalDateTime.now()))) {
            throw new AuthException(HttpStatus.FORBIDDEN, "Account locked");
        }
        if (account.getStatus() == AccountStatus.LOCKED
                && account.getLockedUntil() != null
                && account.getLockedUntil().isBefore(LocalDateTime.now())) {
            account.setStatus(account.isEmailVerified() ? AccountStatus.ACTIVE : AccountStatus.INACTIVE);
            account.setFailedLoginAttempts(0);
            account.setLockedUntil(null);
            userAccountRepository.save(account);
        }
    }

    private void ensureAccountNotBanned(UserAccount account) {
        if (account.getStatus() == AccountStatus.BANNED) {
            throw new AuthException(HttpStatus.FORBIDDEN, "Account banned");
        }
    }

    private void recordFailedLogin(UserAccount account) {
        int failedAttempts = account.getFailedLoginAttempts() + 1;
        account.setFailedLoginAttempts(failedAttempts);
        if (failedAttempts >= authProperties.security().maxFailedLoginAttempts()) {
            account.setStatus(AccountStatus.LOCKED);
            account.setLockedUntil(LocalDateTime.now().plusMinutes(authProperties.security().lockMinutes()));
        }
        userAccountRepository.save(account);
    }

    private void revokeAllRefreshTokens(Long accountId) {
        LocalDateTime now = LocalDateTime.now();
        refreshTokenRepository.findAllByUserAccountIdAndRevokedFalse(accountId).forEach(token -> {
            token.setRevoked(true);
            token.setRevokedAt(now);
            refreshTokenRepository.save(token);
        });
    }

    private UserAccount findAccountByEmail(String email) {
        return userAccountRepository.findByEmailIgnoreCase(normalizeEmail(email))
                .orElseThrow(() -> new BadCredentialsException("Invalid email or password"));
    }

    private UserAccount findAccountById(Long accountId) {
        return userAccountRepository.findById(accountId)
                .orElseThrow(() -> new AuthException(HttpStatus.NOT_FOUND, "Account not found"));
    }

    private AccountResponse toAccountResponse(UserAccount account) {
        return AccountResponse.builder()
                .accountId(account.getId())
                .email(account.getEmail())
                .provider(account.getProvider())
                .role(account.getRole())
                .status(account.getStatus())
                .emailVerified(account.isEmailVerified())
                .build();
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase();
    }

    private String resolveClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (StringUtils.hasText(forwardedFor)) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
