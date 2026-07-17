package com.mss301.authservice.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "auth.admin-account")
public class AdminAccountProperties {

    private String defaultPassword;
}
