package com.mss301.authservice.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "auth.password-reset")
public class PasswordResetProperties {

    private Long tokenExpirationMinutes;
}
