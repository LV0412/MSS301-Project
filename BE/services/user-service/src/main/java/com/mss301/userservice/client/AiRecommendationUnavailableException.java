package com.mss301.userservice.client;

public class AiRecommendationUnavailableException extends RuntimeException {

    public AiRecommendationUnavailableException(String message) {
        super(message);
    }

    public AiRecommendationUnavailableException(String message, Throwable cause) {
        super(message, cause);
    }
}
