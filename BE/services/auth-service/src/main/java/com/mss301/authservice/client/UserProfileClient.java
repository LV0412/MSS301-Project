package com.mss301.authservice.client;

import com.mss301.authservice.entity.UserAccount;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class UserProfileClient {

    private final RestClient restClient;

    public UserProfileClient(
            RestClient.Builder restClientBuilder,
            @Value("${services.user-service.url:http://localhost:8001}") String userServiceUrl) {
        this.restClient = restClientBuilder.baseUrl(userServiceUrl).build();
    }

    public Long ensureUser(UserAccount account) {
        ProvisionUserResponse response = restClient.post()
                .uri("/api/internal/users/provision")
                .body(new ProvisionUserRequest(
                        account.getAccountId(),
                        account.getEmail(),
                        account.getFullName()))
                .retrieve()
                .body(ProvisionUserResponse.class);

        if (response == null || response.userId() == null) {
            throw new IllegalStateException("User service did not return a linked userId");
        }
        return response.userId();
    }

    private record ProvisionUserRequest(Long authAccountId, String email, String fullName) {
    }

    private record ProvisionUserResponse(Long userId) {
    }
}
