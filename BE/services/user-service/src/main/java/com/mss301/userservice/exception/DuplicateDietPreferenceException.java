package com.mss301.userservice.exception;

public class DuplicateDietPreferenceException extends RuntimeException {

    public DuplicateDietPreferenceException(Long userId, String dietType) {
        super("Diet preference already exists for user id " + userId + " and diet type: " + dietType);
    }
}
