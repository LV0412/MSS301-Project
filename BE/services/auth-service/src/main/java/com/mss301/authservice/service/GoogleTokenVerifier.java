package com.mss301.authservice.service;

public interface GoogleTokenVerifier {

    GoogleAccountInfo verify(String idToken);

    record GoogleAccountInfo(
            String providerId,
            String email,
            String fullName
    ) {
    }
}
