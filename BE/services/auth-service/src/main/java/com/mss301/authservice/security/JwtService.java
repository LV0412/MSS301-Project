package com.mss301.authservice.security;

import com.mss301.authservice.config.AuthProperties;
import com.mss301.authservice.domain.UserAccount;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class JwtService {

    private final JwtEncoder jwtEncoder;
    private final AuthProperties authProperties;

    public String generateAccessToken(UserAccount account) {
        Instant now = Instant.now();
        Instant expiresAt = now.plus(authProperties.jwt().accessTokenMinutes(), ChronoUnit.MINUTES);

        JwtClaimsSet claims = JwtClaimsSet.builder()
                .issuer(authProperties.jwt().issuer())
                .issuedAt(now)
                .expiresAt(expiresAt)
                .subject(account.getEmail())
                .claim("type", "access")
                .claim("userId", account.getId())
                .claim("email", account.getEmail())
                .claim("role", account.getRole().name())
                .claim("status", account.getStatus().name())
                .claim("emailVerified", account.isEmailVerified())
                .build();

        return jwtEncoder.encode(JwtEncoderParameters.from(claims)).getTokenValue();
    }

    public long accessTokenExpiresInSeconds() {
        return authProperties.jwt().accessTokenMinutes() * 60;
    }
}
