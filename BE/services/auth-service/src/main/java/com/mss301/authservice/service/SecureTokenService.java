package com.mss301.authservice.service;

public interface SecureTokenService {

    String generateToken();

    String generateOtp();

    String hashToken(String token);

    String hashTokenSha256(String token);

    boolean matches(String rawToken, String tokenHash);
}
