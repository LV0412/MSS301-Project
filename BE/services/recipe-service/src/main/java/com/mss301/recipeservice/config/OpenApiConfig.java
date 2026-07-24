package com.mss301.recipeservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Value("${openapi.server.url:http://localhost:8080}")
    private String serverUrl;

    @Bean
    public OpenAPI recipeServiceOpenAPI() {
        return new OpenAPI()
                .servers(List.of(new Server()
                        .url(serverUrl)
                        .description("API Gateway")))
                .info(new Info()
                        .title("MSS301 Recipe Service API")
                        .version("v1")
                        .description("Recipe, ingredient, category, allergen, and image APIs."));
    }
}
