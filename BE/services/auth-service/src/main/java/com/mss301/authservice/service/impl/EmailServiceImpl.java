package com.mss301.authservice.service.impl;

import com.mss301.authservice.service.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Slf4j
@Service
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;
    private final String mailHost;
    private final String mailUsername;

    public EmailServiceImpl(
            JavaMailSender mailSender,
            @Value("${spring.mail.host:}") String mailHost,
            @Value("${spring.mail.username:}") String mailUsername) {
        this.mailSender = mailSender;
        this.mailHost = mailHost;
        this.mailUsername = mailUsername;
    }

    @Override
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

    @Override
    public void sendPasswordResetToken(String toEmail, String resetToken) {
        if (!StringUtils.hasText(mailHost)) {
            log.info("MAIL_HOST is not configured. Password reset token for {} is {}", toEmail, resetToken);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            if (StringUtils.hasText(mailUsername)) {
                message.setFrom(mailUsername);
            }
            message.setTo(toEmail);
            message.setSubject("MSS301 password reset");
            message.setText("Use this token to reset your password: "
                    + resetToken
                    + "\nThis token will expire soon.");
            mailSender.send(message);
        } catch (RuntimeException exception) {
            log.warn("Failed to send password reset token to {}. Token fallback: {}", toEmail, resetToken, exception);
        }
    }

    @Override
    public void sendTemporaryPassword(String toEmail, String temporaryPassword) {
        if (!StringUtils.hasText(mailHost)) {
            log.info("MAIL_HOST is not configured. Temporary password for {} is {}", toEmail, temporaryPassword);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            if (StringUtils.hasText(mailUsername)) {
                message.setFrom(mailUsername);
            }
            message.setTo(toEmail);
            message.setSubject("MSS301 temporary password");
            message.setText("Your MSS301 account has been created with Google Sign-In.\n"
                    + "Temporary password: " + temporaryPassword + "\n"
                    + "You can use this password for email/password login, then change it in your account settings.");
            mailSender.send(message);
        } catch (RuntimeException exception) {
            log.warn(
                    "Failed to send temporary password to {}. Temporary password fallback: {}",
                    toEmail,
                    temporaryPassword,
                    exception);
        }
    }
}
