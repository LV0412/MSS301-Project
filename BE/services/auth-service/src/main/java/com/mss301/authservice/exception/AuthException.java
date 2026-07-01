package com.mss301.authservice.exception;

import org.springframework.http.HttpStatus;

public class AuthException extends RuntimeException {

    private final ErrorCode code;

    private final HttpStatus status;

    public AuthException(ErrorCode code, String message, HttpStatus status) {
        super(message);
        this.code = code;
        this.status = status;
    }

    public ErrorCode getCode() {
        return code;
    }

    public HttpStatus getStatus() {
        return status;
    }
}
