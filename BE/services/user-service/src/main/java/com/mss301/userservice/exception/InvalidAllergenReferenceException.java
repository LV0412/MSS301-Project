package com.mss301.userservice.exception;

public class InvalidAllergenReferenceException extends RuntimeException {

    public InvalidAllergenReferenceException(Long allergenId) {
        super("Allergen does not exist with id: " + allergenId);
    }
}
