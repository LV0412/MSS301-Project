package com.mss301.userservice.exception;

public class UserAllergyNotFoundException extends RuntimeException {

    public UserAllergyNotFoundException(Long allergyId, Long userId) {
        super("Allergy not found with id " + allergyId + " for user id: " + userId);
    }
}
