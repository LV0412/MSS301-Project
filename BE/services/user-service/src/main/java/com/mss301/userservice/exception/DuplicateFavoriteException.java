package com.mss301.userservice.exception;

public class DuplicateFavoriteException extends RuntimeException {

    public DuplicateFavoriteException(Long userId, Long recipeId) {
        super("Favorite already exists for user id " + userId + " and recipe id: " + recipeId);
    }
}
