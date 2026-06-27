package com.mss301.userservice.exception;

public class NutritionGoalNotFoundException extends RuntimeException {

    public NutritionGoalNotFoundException(Long userId) {
        super("Nutrition goal not found for user id: " + userId);
    }
}
