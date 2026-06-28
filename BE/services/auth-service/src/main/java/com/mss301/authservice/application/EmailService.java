package com.mss301.authservice.application;

import com.mss301.authservice.config.AuthProperties;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class EmailService {

    private static final Logger LOGGER = LoggerFactory.getLogger(EmailService.class);

    private final ObjectProvider<JavaMailSender> mailSenderProvider;
    private final AuthProperties authProperties;

    @Value("${spring.mail.host:}")
    private String mailHost;

    public void sendVerificationOtp(String email, String otpCode) {
        sendOrLog(email, "NutriChef AI verification code", "Your verification code is: " + otpCode);
    }

    public void sendPasswordResetToken(String email, String resetToken) {
        sendOrLog(email, "NutriChef AI password reset", "Your reset token is: " + resetToken);
    }

    private void sendOrLog(String to, String subject, String body) {
        JavaMailSender mailSender = mailSenderProvider.getIfAvailable();
        if (mailSender == null
                || !StringUtils.hasText(mailHost)
                || !StringUtils.hasText(authProperties.mail().from())) {
            LOGGER.info("Mail is not configured. To: {}, subject: {}, body: {}", to, subject, body);
            return;
        }

        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(authProperties.mail().from());
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        mailSender.send(message);
    }
}
