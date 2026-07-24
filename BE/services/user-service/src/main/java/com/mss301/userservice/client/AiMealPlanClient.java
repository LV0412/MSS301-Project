package com.mss301.userservice.client;

import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.server.ResponseStatusException;

@Component
public class AiMealPlanClient {

    private final RestClient aiRecommendationServiceRestClient;

    public AiMealPlanClient(
            @Qualifier("aiRecommendationServiceRestClient") RestClient aiRecommendationServiceRestClient) {
        this.aiRecommendationServiceRestClient = aiRecommendationServiceRestClient;
    }

    public AiGeneratedMealPlanResponse generateMealPlan(Long userId, LocalDate date) {
        try {
            return aiRecommendationServiceRestClient.post()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/ai/internal/meal-plans/generate")
                            .queryParam("date", date)
                            .build())
                    .header("X-User-Id", String.valueOf(userId))
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, (_request, response) -> {
                        if (response.getStatusCode().isSameCodeAs(HttpStatus.UNPROCESSABLE_ENTITY)) {
                            throw new ResponseStatusException(
                                    HttpStatus.UNPROCESSABLE_ENTITY,
                                    "AI recommendation service rejected meal plan constraints");
                        }
                        throw new AiRecommendationUnavailableException(
                                "AI recommendation service rejected meal plan generation with HTTP "
                                        + response.getStatusCode().value());
                    })
                    .body(AiGeneratedMealPlanResponse.class);
        } catch (RestClientException exception) {
            throw new AiRecommendationUnavailableException("AI recommendation service is unavailable", exception);
        }
    }

    public AiGeneratedMealPlanEntry buildSwapCandidate(Long userId, String mealType, Long newRecipeId) {
        try {
            return aiRecommendationServiceRestClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/ai/internal/meal-plans/swap-candidate")
                            .queryParam("mealType", mealType)
                            .queryParam("newRecipeId", newRecipeId)
                            .build())
                    .header("X-User-Id", String.valueOf(userId))
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, (_request, response) -> {
                        if (response.getStatusCode().isSameCodeAs(HttpStatus.UNPROCESSABLE_ENTITY)) {
                            throw new ResponseStatusException(
                                    HttpStatus.UNPROCESSABLE_ENTITY,
                                    "New recipe violates meal plan hard constraints");
                        }
                        throw new AiRecommendationUnavailableException(
                                "AI recommendation service rejected meal plan swap with HTTP "
                                        + response.getStatusCode().value());
                    })
                    .body(AiGeneratedMealPlanEntry.class);
        } catch (RestClientException exception) {
            throw new AiRecommendationUnavailableException("AI recommendation service is unavailable", exception);
        }
    }
}
