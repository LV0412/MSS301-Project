package com.mss301.authservice.service.impl;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.mss301.authservice.client.UserProfileClient;
import com.mss301.authservice.config.AdminAccountProperties;
import com.mss301.authservice.config.AuthSecurityProperties;
import com.mss301.authservice.config.JwtProperties;
import com.mss301.authservice.config.PasswordResetProperties;
import com.mss301.authservice.config.RateLimitProperties;
import com.mss301.authservice.config.VerificationProperties;
import com.mss301.authservice.dto.AuthResponse;
import com.mss301.authservice.dto.GoogleLoginRequest;
import com.mss301.authservice.dto.LoginRequest;
import com.mss301.authservice.entity.AccountRole;
import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.AuthProvider;
import com.mss301.authservice.entity.RefreshToken;
import com.mss301.authservice.entity.UserAccount;
import com.mss301.authservice.repository.EmailVerificationRepository;
import com.mss301.authservice.repository.PasswordResetTokenRepository;
import com.mss301.authservice.repository.RefreshTokenRepository;
import com.mss301.authservice.repository.UserAccountRepository;
import com.mss301.authservice.security.JwtService;
import com.mss301.authservice.service.EmailService;
import com.mss301.authservice.service.GoogleTokenVerifier;
import com.mss301.authservice.service.RateLimiter;
import com.mss301.authservice.service.SecureTokenService;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {

    @Mock
    private UserAccountRepository userAccountRepository;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private EmailVerificationRepository emailVerificationRepository;

    @Mock
    private PasswordResetTokenRepository passwordResetTokenRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private JwtProperties jwtProperties;

    @Mock
    private VerificationProperties verificationProperties;

    @Mock
    private PasswordResetProperties passwordResetProperties;

    @Mock
    private AuthSecurityProperties authSecurityProperties;

    @Mock
    private AdminAccountProperties adminAccountProperties;

    @Mock
    private RateLimitProperties rateLimitProperties;

    @Mock
    private SecureTokenService secureTokenService;

    @Mock
    private EmailService emailService;

    @Mock
    private GoogleTokenVerifier googleTokenVerifier;

    @Mock
    private RateLimiter rateLimiter;

    @Mock
    private UserProfileClient userProfileClient;

    private AuthServiceImpl authService;

    @BeforeEach
    void setUp() {
        authService = new AuthServiceImpl(
                userAccountRepository,
                refreshTokenRepository,
                emailVerificationRepository,
                passwordResetTokenRepository,
                passwordEncoder,
                jwtService,
                jwtProperties,
                verificationProperties,
                passwordResetProperties,
                authSecurityProperties,
                adminAccountProperties,
                rateLimitProperties,
                secureTokenService,
                emailService,
                googleTokenVerifier,
                rateLimiter,
                userProfileClient);

        when(jwtProperties.getAccessTokenExpirationMinutes()).thenReturn(15L);
        when(jwtProperties.getRefreshTokenExpirationDays()).thenReturn(7L);
        when(secureTokenService.generateToken()).thenReturn("refresh-secret");
        when(secureTokenService.hashToken("refresh-secret")).thenReturn("refresh-secret-hash");
        when(jwtService.generateAccessToken(any(UserAccount.class), any(Long.class))).thenReturn("access-token");
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(userProfileClient.ensureUser(any(UserAccount.class))).thenReturn(99L);
    }

    @Test
    void googleLoginCreatesGoogleAccountWithTemporaryPasswordAndSendsEmail() {
        GoogleTokenVerifier.GoogleAccountInfo googleAccount = new GoogleTokenVerifier.GoogleAccountInfo(
                "google-id-1",
                "new.user@gmail.com",
                "New User");

        when(googleTokenVerifier.verify("id-token")).thenReturn(googleAccount);
        when(userAccountRepository.findByGoogleProviderId("google-id-1")).thenReturn(Optional.empty());
        when(userAccountRepository.findByProviderAndProviderId(AuthProvider.GOOGLE, "google-id-1"))
                .thenReturn(Optional.empty());
        when(userAccountRepository.findByEmailIgnoreCase("new.user@gmail.com")).thenReturn(Optional.empty());
        when(secureTokenService.generateTemporaryPassword()).thenReturn("TempPassword123");
        when(passwordEncoder.encode("TempPassword123")).thenReturn("encoded-temp-password");
        when(userAccountRepository.save(any(UserAccount.class))).thenAnswer(invocation -> {
            UserAccount account = invocation.getArgument(0);
            account.setAccountId(1L);
            return account;
        });

        AuthResponse response = authService.googleLogin(new GoogleLoginRequest("id-token", null));

        ArgumentCaptor<UserAccount> accountCaptor = ArgumentCaptor.forClass(UserAccount.class);
        verify(userAccountRepository).save(accountCaptor.capture());
        UserAccount savedAccount = accountCaptor.getValue();
        assertThat(savedAccount.getEmail()).isEqualTo("new.user@gmail.com");
        assertThat(savedAccount.getPasswordHash()).isEqualTo("encoded-temp-password");
        assertThat(savedAccount.getProvider()).isEqualTo(AuthProvider.GOOGLE);
        assertThat(savedAccount.getProviderId()).isEqualTo("google-id-1");
        assertThat(savedAccount.getGoogleProviderId()).isEqualTo("google-id-1");
        assertThat(savedAccount.getStatus()).isEqualTo(AccountStatus.ACTIVE);
        assertThat(savedAccount.getEmailVerified()).isTrue();
        verify(emailService).sendTemporaryPassword("new.user@gmail.com", "TempPassword123");
        verify(jwtService).generateAccessToken(any(UserAccount.class), eq(99L));
        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.refreshToken()).endsWith(".refresh-secret");
        assertThat(response.account().provider()).isEqualTo(AuthProvider.GOOGLE);
    }

    @Test
    void loginAcceptsGoogleAccountWhenPasswordHashExists() {
        UserAccount account = UserAccount.builder()
                .accountId(2L)
                .email("google.user@gmail.com")
                .passwordHash("encoded-temp-password")
                .fullName("Google User")
                .role(AccountRole.USER)
                .status(AccountStatus.ACTIVE)
                .emailVerified(true)
                .provider(AuthProvider.GOOGLE)
                .providerId("google-id-2")
                .googleProviderId("google-id-2")
                .failedLoginAttempts(0)
                .build();

        when(userAccountRepository.findByEmailIgnoreCase("google.user@gmail.com")).thenReturn(Optional.of(account));
        when(passwordEncoder.matches("TempPassword123", "encoded-temp-password")).thenReturn(true);

        AuthResponse response = authService.login(new LoginRequest("google.user@gmail.com", "TempPassword123"));

        verify(jwtService).generateAccessToken(account, 99L);
        assertThat(response.accessToken()).isEqualTo("access-token");
        assertThat(response.account().provider()).isEqualTo(AuthProvider.GOOGLE);
        assertThat(account.getFailedLoginAttempts()).isZero();
    }
}
