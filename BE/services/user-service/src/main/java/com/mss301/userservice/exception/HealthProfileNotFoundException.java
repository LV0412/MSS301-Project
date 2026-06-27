package com.mss301.userservice.exception;

public class HealthProfileNotFoundException extends RuntimeException {

    public HealthProfileNotFoundException(Long userId) {
        super("Health profile not found for user id: " + userId);
    }
}
