package com.mss301.authservice.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "auth.rate-limit")
public class RateLimitProperties {

    private Long windowSeconds;

    private Integer loginLimit;

    private Integer resendOtpLimit;

    private Integer verifyEmailLimit;

    private Integer forgotPasswordLimit;

    private Integer resetPasswordLimit;
}
