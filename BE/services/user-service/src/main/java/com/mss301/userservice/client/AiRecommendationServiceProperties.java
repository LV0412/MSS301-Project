package com.mss301.userservice.client;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.ai-recommendation-service")
public record AiRecommendationServiceProperties(String baseUrl) {

    public AiRecommendationServiceProperties {
        if (baseUrl == null || baseUrl.isBlank()) {
            baseUrl = "http://localhost:8004";
        }
    }
}
