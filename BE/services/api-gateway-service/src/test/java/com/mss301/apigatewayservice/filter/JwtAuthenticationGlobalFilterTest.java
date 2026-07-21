package com.mss301.apigatewayservice.filter;

import static org.assertj.core.api.Assertions.assertThat;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;
import javax.crypto.SecretKey;
import org.junit.jupiter.api.Test;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

class JwtAuthenticationGlobalFilterTest {

    private static final String SECRET = "test-secret-key-with-at-least-32-bytes-long";

    private final JwtAuthenticationGlobalFilter filter = new JwtAuthenticationGlobalFilter(SECRET, "", "");

    @Test
    void publicRouteStripsClientSuppliedIdentityHeaders() {
        MockServerWebExchange exchange = MockServerWebExchange.from(MockServerHttpRequest
                .post("/api/v1/auth/login")
                .header("X-User-Id", "999")
                .header("X-User-Role", "ADMIN"));
        AtomicReference<ServerWebExchange> forwardedExchange = new AtomicReference<>();

        filter.filter(exchange, capture(forwardedExchange)).block();

        HttpHeaders headers = forwardedExchange.get().getRequest().getHeaders();
        assertThat(headers.containsKey("X-User-Id")).isFalse();
        assertThat(headers.containsKey("X-User-Role")).isFalse();
        assertThat(exchange.getResponse().getStatusCode()).isNull();
    }

    @Test
    void protectedRouteInjectsTrustedIdentityHeadersFromJwt() {
        String token = token("7", "42", "user@example.com", "USER");
        MockServerWebExchange exchange = MockServerWebExchange.from(MockServerHttpRequest
                .get("/api/v1/users/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .header("X-User-Id", "999")
                .header("X-User-Role", "ADMIN"));
        AtomicReference<ServerWebExchange> forwardedExchange = new AtomicReference<>();

        filter.filter(exchange, capture(forwardedExchange)).block();

        HttpHeaders headers = forwardedExchange.get().getRequest().getHeaders();
        assertThat(headers.getFirst("X-Account-Id")).isEqualTo("7");
        assertThat(headers.getFirst("X-User-Id")).isEqualTo("42");
        assertThat(headers.getFirst("X-User-Email")).isEqualTo("user@example.com");
        assertThat(headers.getFirst("X-User-Role")).isEqualTo("USER");
        assertThat(exchange.getResponse().getStatusCode()).isNull();
    }

    @Test
    void protectedRouteRejectsMissingJwt() {
        MockServerWebExchange exchange = MockServerWebExchange.from(MockServerHttpRequest.get("/api/v1/users/me"));

        filter.filter(exchange, capture(new AtomicReference<>())).block();

        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void adminRouteRejectsNonAdminRole() {
        String token = token("7", "42", "user@example.com", "USER");
        MockServerWebExchange exchange = MockServerWebExchange.from(MockServerHttpRequest
                .method(HttpMethod.POST, "/api/v1/auth/admin/accounts")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token));

        filter.filter(exchange, capture(new AtomicReference<>())).block();

        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    private GatewayFilterChain capture(AtomicReference<ServerWebExchange> forwardedExchange) {
        return exchange -> {
            forwardedExchange.set(exchange);
            return Mono.empty();
        };
    }

    private String token(String accountId, String userId, String email, String role) {
        SecretKey key = Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));
        Instant now = Instant.now();
        return Jwts.builder()
                .claims(Map.of(
                        "accountId", accountId,
                        "userId", userId,
                        "email", email,
                        "role", role,
                        "status", "ACTIVE",
                        "emailVerified", true))
                .subject(email)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(900)))
                .signWith(key)
                .compact();
    }
}
