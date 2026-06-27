package com.mss301.userservice.exception;

public class NutritionGoalAlreadyExistsException extends RuntimeException {

    public NutritionGoalAlreadyExistsException(Long userId) {
        super("Nutrition goal already exists for user id: " + userId);
    }
}
