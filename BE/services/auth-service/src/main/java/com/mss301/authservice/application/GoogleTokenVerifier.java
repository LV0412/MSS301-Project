package com.mss301.authservice.application;

import com.mss301.authservice.config.AuthProperties;
import com.mss301.authservice.exception.AuthException;
import java.util.List;
import lombok.Builder;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtDecoders;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class GoogleTokenVerifier {

    private final AuthProperties authProperties;

    public GoogleAccount verify(String idToken) {
        if (!StringUtils.hasText(authProperties.google().clientId())) {
            throw new AuthException(HttpStatus.SERVICE_UNAVAILABLE, "Google login is not configured");
        }

        try {
            JwtDecoder decoder = JwtDecoders.fromIssuerLocation("https://accounts.google.com");
            Jwt jwt = decoder.decode(idToken);
            List<String> audience = jwt.getAudience();
            Boolean emailVerified = jwt.getClaimAsBoolean("email_verified");

            if (!audience.contains(authProperties.google().clientId())) {
                throw new AuthException(HttpStatus.UNAUTHORIZED, "Invalid Google token audience");
            }
            if (!Boolean.TRUE.equals(emailVerified)) {
                throw new AuthException(HttpStatus.FORBIDDEN, "Google email is not verified");
            }

            return GoogleAccount.builder()
                    .providerId(jwt.getSubject())
                    .email(jwt.getClaimAsString("email"))
                    .build();
        } catch (JwtException exception) {
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Invalid Google token");
        }
    }

    @Builder
    public record GoogleAccount(String providerId, String email) {
    }
}
