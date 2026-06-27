package com.mss301.userservice.exception;

public class FavoriteNotFoundException extends RuntimeException {

    public FavoriteNotFoundException(Long favoriteId, Long userId) {
        super("Favorite not found with id " + favoriteId + " for user id: " + userId);
    }
}
