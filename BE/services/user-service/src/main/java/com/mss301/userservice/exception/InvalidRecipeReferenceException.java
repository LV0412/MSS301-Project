package com.mss301.userservice.exception;

public class InvalidRecipeReferenceException extends RuntimeException {

    public InvalidRecipeReferenceException(Long recipeId) {
        super("Recipe does not exist with id: " + recipeId);
    }
}
