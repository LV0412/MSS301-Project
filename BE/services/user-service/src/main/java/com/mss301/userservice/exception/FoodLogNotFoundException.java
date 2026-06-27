package com.mss301.userservice.exception;

public class FoodLogNotFoundException extends RuntimeException {

    public FoodLogNotFoundException(Long logId, Long userId) {
        super("Food log not found with id " + logId + " for user id: " + userId);
    }
}
