package com.mss301.recipeservice.exception;

public class DuplicateResourceException extends RuntimeException {
    public DuplicateResourceException(String resource, String value) {
        super(resource + " already exists: " + value);
    }
}
