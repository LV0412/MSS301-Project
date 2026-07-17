package com.mss301.recipeservice.config;

import com.cloudinary.Cloudinary;
import java.util.HashMap;
import java.util.Map;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(CloudinaryProperties.class)
public class CloudinaryConfig {

    @Bean
    public Cloudinary cloudinary(CloudinaryProperties properties) {
        Map<String, Object> config = new HashMap<>();
        config.put("cloud_name", defaultString(properties.getCloudName()));
        config.put("api_key", defaultString(properties.getApiKey()));
        config.put("api_secret", defaultString(properties.getApiSecret()));
        config.put("secure", true);
        return new Cloudinary(config);
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }
}
