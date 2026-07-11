package com.mss301.authservice.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.mss301.authservice.config.GoogleProperties;
import com.mss301.authservice.exception.AuthException;
import com.mss301.authservice.exception.ErrorCode;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class GoogleTokenVerifier {

    private final GoogleProperties googleProperties;

    public GoogleTokenVerifier(GoogleProperties googleProperties) {
        this.googleProperties = googleProperties;
    }

    public GoogleAccountInfo verify(String idToken) {
        if (!StringUtils.hasText(googleProperties.getClientId())) {
            throw new AuthException(
                    ErrorCode.GOOGLE_AUTH_UNAVAILABLE,
                    "Google authentication is currently unavailable.",
                    HttpStatus.SERVICE_UNAVAILABLE);
        }

        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance())
                    .setAudience(List.of(googleProperties.getClientId()))
                    .build();

            GoogleIdToken verifiedToken = verifier.verify(idToken);
            if (verifiedToken == null) {
                throw new AuthException(
                        ErrorCode.INVALID_GOOGLE_TOKEN,
                        "Invalid Google ID token",
                        HttpStatus.UNAUTHORIZED);
            }

            GoogleIdToken.Payload payload = verifiedToken.getPayload();
            if (!Boolean.TRUE.equals(payload.getEmailVerified())) {
                throw new AuthException(
                        ErrorCode.GOOGLE_EMAIL_NOT_VERIFIED,
                        "Google email is not verified",
                        HttpStatus.UNAUTHORIZED);
            }

            String email = payload.getEmail();
            String fullName = payload.get("name") instanceof String name && StringUtils.hasText(name)
                    ? name
                    : email;

            return new GoogleAccountInfo(payload.getSubject(), email, fullName);
        } catch (GeneralSecurityException | IOException | IllegalArgumentException exception) {
            throw new AuthException(
                    ErrorCode.INVALID_GOOGLE_TOKEN,
                    "Unable to verify Google ID token",
                    HttpStatus.UNAUTHORIZED);
        }
    }

    public record GoogleAccountInfo(
            String providerId,
            String email,
            String fullName
    ) {
    }
}
