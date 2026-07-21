package com.mss301.apigatewayservice.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.List;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class JwtAuthenticationGlobalFilter implements GlobalFilter, Ordered {

    private static final String BEARER_PREFIX = "Bearer ";
    private static final String ACCOUNT_ID_CLAIM = "accountId";
    private static final String USER_ID_CLAIM = "userId";
    private static final String EMAIL_CLAIM = "email";
    private static final String ROLE_CLAIM = "role";

    private static final String X_ACCOUNT_ID = "X-Account-Id";
    private static final String X_USER_ID = "X-User-Id";
    private static final String X_USER_EMAIL = "X-User-Email";
    private static final String X_USER_ROLE = "X-User-Role";

    private static final List<String> TRUSTED_IDENTITY_HEADERS = List.of(
            X_ACCOUNT_ID,
            X_USER_ID,
            X_USER_EMAIL,
            X_USER_ROLE);

    private final SecretKey signingKey;
    private final String issuer;
    private final String audience;

    public JwtAuthenticationGlobalFilter(
            @Value("${gateway.jwt.secret}") String jwtSecret,
            @Value("${gateway.jwt.issuer:}") String issuer,
            @Value("${gateway.jwt.audience:}") String audience) {
        this.signingKey = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
        this.issuer = issuer;
        this.audience = audience;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest sanitizedRequest = stripTrustedIdentityHeaders(exchange.getRequest());
        ServerWebExchange sanitizedExchange = exchange.mutate().request(sanitizedRequest).build();
        String path = sanitizedRequest.getURI().getPath();

        if (isPublicRoute(sanitizedRequest.getMethod(), path)) {
            return chain.filter(sanitizedExchange);
        }

        String token = extractBearerToken(sanitizedRequest);
        if (!StringUtils.hasText(token)) {
            return reject(sanitizedExchange, HttpStatus.UNAUTHORIZED);
        }

        Claims claims;
        try {
            claims = parseClaims(token);
        } catch (JwtException | IllegalArgumentException exception) {
            return reject(sanitizedExchange, HttpStatus.UNAUTHORIZED);
        }

        String accountId;
        String userId;
        String email;
        String role;
        try {
            accountId = requiredStringClaim(claims, ACCOUNT_ID_CLAIM);
            userId = requiredStringClaim(claims, USER_ID_CLAIM);
            email = requiredStringClaim(claims, EMAIL_CLAIM);
            role = requiredStringClaim(claims, ROLE_CLAIM);
        } catch (JwtException exception) {
            return reject(sanitizedExchange, HttpStatus.UNAUTHORIZED);
        }

        if (requiresAdmin(path) && !isAdmin(role)) {
            return reject(sanitizedExchange, HttpStatus.FORBIDDEN);
        }

        ServerHttpRequest authenticatedRequest = sanitizedRequest.mutate()
                .header(X_ACCOUNT_ID, accountId)
                .header(X_USER_ID, userId)
                .header(X_USER_EMAIL, email)
                .header(X_USER_ROLE, role)
                .build();

        return chain.filter(sanitizedExchange.mutate().request(authenticatedRequest).build());
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }

    private ServerHttpRequest stripTrustedIdentityHeaders(ServerHttpRequest request) {
        return request.mutate()
                .headers(headers -> TRUSTED_IDENTITY_HEADERS.forEach(headers::remove))
                .build();
    }

    private boolean isPublicRoute(HttpMethod method, String path) {
        if (HttpMethod.OPTIONS.equals(method)) {
            return true;
        }
        if (path.startsWith("/swagger-ui/")
                || path.equals("/swagger-ui.html")
                || path.startsWith("/webjars/")
                || path.startsWith("/v3/api-docs")
                || path.startsWith("/gateway/v3/api-docs")
                || path.equals("/actuator/health")
                || path.equals("/actuator/info")) {
            return true;
        }
        return HttpMethod.POST.equals(method) && (
                path.equals("/api/v1/auth/register")
                        || path.equals("/api/v1/auth/login")
                        || path.equals("/api/v1/auth/google")
                        || path.equals("/api/v1/auth/refresh")
                        || path.equals("/api/v1/auth/verify-email")
                        || path.equals("/api/v1/auth/resend-otp")
                        || path.equals("/api/v1/auth/forgot-password")
                        || path.equals("/api/v1/auth/reset-password"));
    }

    private String extractBearerToken(ServerHttpRequest request) {
        String authorization = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (!StringUtils.hasText(authorization) || !authorization.startsWith(BEARER_PREFIX)) {
            return null;
        }
        return authorization.substring(BEARER_PREFIX.length());
    }

    private Claims parseClaims(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
        validateOptionalRegisteredClaims(claims);
        return claims;
    }

    private void validateOptionalRegisteredClaims(Claims claims) {
        if (StringUtils.hasText(issuer) && !issuer.equals(claims.getIssuer())) {
            throw new JwtException("Invalid token issuer");
        }
        if (StringUtils.hasText(audience) && !claimContainsAudience(claims.getAudience(), audience)) {
            throw new JwtException("Invalid token audience");
        }
    }

    private boolean claimContainsAudience(Object claimAudience, String requiredAudience) {
        if (claimAudience instanceof String audienceValue) {
            return requiredAudience.equals(audienceValue);
        }
        if (claimAudience instanceof Iterable<?> audienceValues) {
            for (Object value : audienceValues) {
                if (requiredAudience.equals(String.valueOf(value))) {
                    return true;
                }
            }
        }
        return false;
    }

    private boolean requiresAdmin(String path) {
        return path.equals("/admin")
                || path.startsWith("/admin/")
                || path.contains("/admin/");
    }

    private boolean isAdmin(String role) {
        return "ADMIN".equals(role) || "ROLE_ADMIN".equals(role);
    }

    private String requiredStringClaim(Claims claims, String claimName) {
        Object value = claims.get(claimName);
        if (value == null || !StringUtils.hasText(String.valueOf(value))) {
            throw new JwtException("Missing token claim: " + claimName);
        }
        return String.valueOf(value);
    }

    private Mono<Void> reject(ServerWebExchange exchange, HttpStatus status) {
        exchange.getResponse().setStatusCode(status);
        return exchange.getResponse().setComplete();
    }
}
