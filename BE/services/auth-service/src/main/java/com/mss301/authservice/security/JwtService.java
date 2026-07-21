package com.mss301.authservice.security;

import com.mss301.authservice.config.JwtProperties;
import com.mss301.authservice.entity.AccountRole;
import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.UserAccount;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.Map;
import javax.crypto.SecretKey;
import org.springframework.stereotype.Service;

@Service
public class JwtService {

    private static final String ACCOUNT_ID_CLAIM = "accountId";
    private static final String USER_ID_CLAIM = "userId";
    private static final String EMAIL_CLAIM = "email";
    private static final String ROLE_CLAIM = "role";
    private static final String STATUS_CLAIM = "status";
    private static final String EMAIL_VERIFIED_CLAIM = "emailVerified";

    private final JwtProperties jwtProperties;

    public JwtService(JwtProperties jwtProperties) {
        this.jwtProperties = jwtProperties;
    }

    public String generateAccessToken(UserAccount account, Long userId) {
        Instant now = Instant.now();
        Instant expiresAt = now.plus(jwtProperties.getAccessTokenExpirationMinutes(), ChronoUnit.MINUTES);

        Map<String, Object> claims = Map.of(
                ACCOUNT_ID_CLAIM, account.getAccountId(),
                USER_ID_CLAIM, userId,
                EMAIL_CLAIM, account.getEmail(),
                ROLE_CLAIM, account.getRole().name(),
                STATUS_CLAIM, account.getStatus().name(),
                EMAIL_VERIFIED_CLAIM, account.getEmailVerified()
        );

        return Jwts.builder()
                .claims(claims)
                .subject(account.getEmail())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiresAt))
                .signWith(signingKey())
                .compact();
    }

    public boolean isTokenValid(String token) {
        try {
            parseClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException exception) {
            return false;
        }
    }

    public AuthUserPrincipal buildPrincipal(String token) {
        Claims claims = parseClaims(token);
        return AuthUserPrincipal.builder()
                .accountId(extractAccountId(claims))
                .email(claims.get(EMAIL_CLAIM, String.class))
                .role(AccountRole.valueOf(claims.get(ROLE_CLAIM, String.class)))
                .status(AccountStatus.valueOf(claims.get(STATUS_CLAIM, String.class)))
                .emailVerified(claims.get(EMAIL_VERIFIED_CLAIM, Boolean.class))
                .build();
    }

    public Long extractAccountId(String token) {
        return extractAccountId(parseClaims(token));
    }

    public String extractEmail(String token) {
        return parseClaims(token).get(EMAIL_CLAIM, String.class);
    }

    public AccountRole extractRole(String token) {
        return AccountRole.valueOf(parseClaims(token).get(ROLE_CLAIM, String.class));
    }

    public AccountStatus extractStatus(String token) {
        return AccountStatus.valueOf(parseClaims(token).get(STATUS_CLAIM, String.class));
    }

    public Boolean extractEmailVerified(String token) {
        return parseClaims(token).get(EMAIL_VERIFIED_CLAIM, Boolean.class);
    }

    private Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(signingKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private Long extractAccountId(Claims claims) {
        Number accountId = claims.get(ACCOUNT_ID_CLAIM, Number.class);
        return accountId.longValue();
    }

    private SecretKey signingKey() {
        byte[] keyBytes = jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}
