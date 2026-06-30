package com.mss301.authservice.config;

import jakarta.annotation.PostConstruct;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class StartupConfigValidator {

    private static final String DEFAULT_JWT_SECRET = "change-this-secret-before-running-change-this-secret-before-running";
    private static final String EXAMPLE_JWT_SECRET = "change-this-to-a-long-random-secret-at-least-32-bytes-long";

    private final Environment environment;
    private final JwtProperties jwtProperties;
    private final String databasePassword;
    private final String ddlAuto;

    public StartupConfigValidator(
            Environment environment,
            JwtProperties jwtProperties,
            @Value("${spring.datasource.password:}") String databasePassword,
            @Value("${spring.jpa.hibernate.ddl-auto:}") String ddlAuto) {
        this.environment = environment;
        this.jwtProperties = jwtProperties;
        this.databasePassword = databasePassword;
        this.ddlAuto = ddlAuto;
    }

    @PostConstruct
    public void validate() {
        validateJwtConfig();

        if (isProduction()) {
            validateProductionConfig();
        }
    }

    private void validateJwtConfig() {
        if (!StringUtils.hasText(jwtProperties.getSecret()) || jwtProperties.getSecret().length() < 32) {
            throw new IllegalStateException("JWT_SECRET must be at least 32 characters long.");
        }
        if (jwtProperties.getAccessTokenExpirationMinutes() == null
                || jwtProperties.getAccessTokenExpirationMinutes() <= 0) {
            throw new IllegalStateException("JWT_ACCESS_TOKEN_EXPIRATION_MINUTES must be greater than 0.");
        }
        if (jwtProperties.getRefreshTokenExpirationDays() == null
                || jwtProperties.getRefreshTokenExpirationDays() <= 0) {
            throw new IllegalStateException("JWT_REFRESH_TOKEN_EXPIRATION_DAYS must be greater than 0.");
        }
        long refreshMinutes = jwtProperties.getRefreshTokenExpirationDays() * 24 * 60;
        if (refreshMinutes <= jwtProperties.getAccessTokenExpirationMinutes()) {
            throw new IllegalStateException("Refresh token expiration must be greater than access token expiration.");
        }
    }

    private void validateProductionConfig() {
        if (DEFAULT_JWT_SECRET.equals(jwtProperties.getSecret()) || EXAMPLE_JWT_SECRET.equals(jwtProperties.getSecret())) {
            throw new IllegalStateException("Default JWT_SECRET is not allowed in production.");
        }
        if (!StringUtils.hasText(databasePassword)) {
            throw new IllegalStateException("AUTH_DATABASE_PASSWORD must not be empty in production.");
        }
        if ("create".equalsIgnoreCase(ddlAuto) || "create-drop".equalsIgnoreCase(ddlAuto)) {
            throw new IllegalStateException("JPA ddl-auto create/create-drop is not allowed in production.");
        }
    }

    private boolean isProduction() {
        String appEnv = environment.getProperty("APP_ENV", "");
        return "prod".equalsIgnoreCase(appEnv)
                || "production".equalsIgnoreCase(appEnv)
                || Arrays.stream(environment.getActiveProfiles())
                .anyMatch(profile -> "prod".equalsIgnoreCase(profile) || "production".equalsIgnoreCase(profile));
    }
}
