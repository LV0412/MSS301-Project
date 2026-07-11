package com.mss301.authservice.service;

public interface EmailService {

    void sendVerificationOtp(String toEmail, String otp);

    void sendPasswordResetToken(String toEmail, String resetToken);
}
