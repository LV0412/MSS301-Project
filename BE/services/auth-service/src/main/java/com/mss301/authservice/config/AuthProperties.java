package com.mss301.authservice.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "auth")
public record AuthProperties(
        Jwt jwt,
        Google google,
        Mail mail,
        Security security
) {
    public record Jwt(
            String secret,
            String issuer,
            long accessTokenMinutes,
            long refreshTokenDays
    ) {
    }

    public record Google(String clientId) {
    }

    public record Mail(String from) {
    }

    public record Security(
            int maxFailedLoginAttempts,
            long lockMinutes,
            long otpExpiryMinutes,
            long resetTokenExpiryMinutes,
            long resendOtpCooldownSeconds
    ) {
    }
}
