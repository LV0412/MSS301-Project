package com.mss301.authservice.service;

import com.mss301.authservice.config.JwtProperties;
import com.mss301.authservice.config.VerificationProperties;
import com.mss301.authservice.dto.AccountResponse;
import com.mss301.authservice.dto.AuthResponse;
import com.mss301.authservice.dto.EmailRequest;
import com.mss301.authservice.dto.LoginRequest;
import com.mss301.authservice.dto.MessageResponse;
import com.mss301.authservice.dto.RegisterRequest;
import com.mss301.authservice.dto.VerifyEmailRequest;
import com.mss301.authservice.entity.AccountRole;
import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.AuthProvider;
import com.mss301.authservice.entity.EmailVerification;
import com.mss301.authservice.entity.RefreshToken;
import com.mss301.authservice.entity.UserAccount;
import com.mss301.authservice.exception.AuthException;
import com.mss301.authservice.repository.EmailVerificationRepository;
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
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final JwtProperties jwtProperties;
    private final VerificationProperties verificationProperties;
    private final SecureTokenService secureTokenService;
    private final EmailService emailService;

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
                .orElseThrow(() -> new AuthException("Invalid email or password", HttpStatus.UNAUTHORIZED));

        if (account.getProvider() != AuthProvider.LOCAL || account.getPasswordHash() == null) {
            throw new AuthException("Invalid email or password", HttpStatus.UNAUTHORIZED);
        }

        if (!passwordEncoder.matches(request.password(), account.getPasswordHash())) {
            throw new AuthException("Invalid email or password", HttpStatus.UNAUTHORIZED);
        }

        ensureAccountCanLogin(account);

        String accessToken = jwtService.generateAccessToken(account);
        String refreshToken = createRefreshToken(account);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
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
                .orElseThrow(() -> new AuthException("Verification OTP not found", HttpStatus.BAD_REQUEST));

        if (LocalDateTime.now().isAfter(verification.getExpiresAt())) {
            throw new AuthException("Verification OTP has expired", HttpStatus.BAD_REQUEST);
        }

        if (!secureTokenService.matches(request.otp(), verification.getOtpHash())) {
            throw new AuthException("Invalid verification OTP", HttpStatus.BAD_REQUEST);
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

    private String createRefreshToken(UserAccount account) {
        String rawToken = secureTokenService.generateToken();
        RefreshToken refreshToken = RefreshToken.builder()
                .userAccount(account)
                .tokenHash(secureTokenService.hashToken(rawToken))
                .expiresAt(LocalDateTime.now().plusDays(jwtProperties.getRefreshTokenExpirationDays()))
                .build();
        refreshTokenRepository.save(refreshToken);
        return rawToken;
    }

    private void ensureEmailIsAvailable(String email) {
        if (userAccountRepository.existsByEmailIgnoreCase(email)) {
            throw new AuthException("Email already exists", HttpStatus.CONFLICT);
        }
    }

    private UserAccount findAccountByEmail(String email) {
        return userAccountRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new AuthException("Account not found", HttpStatus.NOT_FOUND));
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

    private void ensureAccountCanLogin(UserAccount account) {
        if (account.getStatus() == AccountStatus.LOCKED) {
            throw new AuthException("Account is locked", HttpStatus.FORBIDDEN);
        }
        if (account.getStatus() != AccountStatus.ACTIVE || !Boolean.TRUE.equals(account.getEmailVerified())) {
            throw new AuthException("Please verify your email before logging in", HttpStatus.FORBIDDEN);
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
}
