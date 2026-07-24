package com.mss301.userservice.config;

import com.mss301.userservice.client.AiRecommendationServiceProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
@EnableConfigurationProperties(AiRecommendationServiceProperties.class)
public class AiRecommendationServiceClientConfig {

    @Bean
    RestClient aiRecommendationServiceRestClient(
            RestClient.Builder builder,
            AiRecommendationServiceProperties properties) {
        return builder.baseUrl(properties.baseUrl()).build();
    }
}
