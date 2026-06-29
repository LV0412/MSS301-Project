package com.mss301.authservice.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Slf4j
@Service
public class EmailService {

    private final JavaMailSender mailSender;
    private final String mailHost;
    private final String mailUsername;

    public EmailService(
            JavaMailSender mailSender,
            @Value("${spring.mail.host:}") String mailHost,
            @Value("${spring.mail.username:}") String mailUsername) {
        this.mailSender = mailSender;
        this.mailHost = mailHost;
        this.mailUsername = mailUsername;
    }

    public void sendVerificationOtp(String toEmail, String otp) {
        if (!StringUtils.hasText(mailHost)) {
            log.info("MAIL_HOST is not configured. Verification OTP for {} is {}", toEmail, otp);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            if (StringUtils.hasText(mailUsername)) {
                message.setFrom(mailUsername);
            }
            message.setTo(toEmail);
            message.setSubject("MSS301 email verification code");
            message.setText("Your verification code is: " + otp + "\nThis code will expire soon.");
            mailSender.send(message);
        } catch (RuntimeException exception) {
            log.warn("Failed to send verification OTP to {}. OTP fallback: {}", toEmail, otp, exception);
        }
    }
}
