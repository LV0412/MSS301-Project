package com.mss301.userservice.exception;

public class DuplicateUserAllergyException extends RuntimeException {

    public DuplicateUserAllergyException(Long userId, Long allergenId) {
        super("Allergy already exists for user id " + userId + " and allergen id: " + allergenId);
    }
}
