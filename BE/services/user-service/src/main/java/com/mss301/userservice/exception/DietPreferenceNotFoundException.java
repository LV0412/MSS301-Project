package com.mss301.userservice.exception;

public class DietPreferenceNotFoundException extends RuntimeException {

    public DietPreferenceNotFoundException(Long preferenceId, Long userId) {
        super("Diet preference not found with id " + preferenceId + " for user id: " + userId);
    }
}
