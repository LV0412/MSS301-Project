package com.mss301.userservice.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
@EnableConfigurationProperties(RecipeServiceProperties.class)
public class RecipeServiceClientConfig {

    @Bean
    RestClient recipeServiceRestClient(RestClient.Builder builder, RecipeServiceProperties properties) {
        return builder.baseUrl(properties.baseUrl()).build();
    }
}
