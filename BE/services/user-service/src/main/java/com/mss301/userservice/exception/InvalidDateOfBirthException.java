package com.mss301.userservice.exception;

public class InvalidDateOfBirthException extends RuntimeException {

    public InvalidDateOfBirthException(int minAge, int maxAge) {
        super("User age must be between " + minAge + " and " + maxAge + " years old");
    }
}
