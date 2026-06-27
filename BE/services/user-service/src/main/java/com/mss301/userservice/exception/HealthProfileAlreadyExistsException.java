package com.mss301.userservice.exception;

public class HealthProfileAlreadyExistsException extends RuntimeException {

    public HealthProfileAlreadyExistsException(Long userId) {
        super("Health profile already exists for user id: " + userId);
    }
}
