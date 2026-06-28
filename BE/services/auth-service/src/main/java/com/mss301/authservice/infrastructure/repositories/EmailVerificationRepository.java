package com.mss301.authservice.infrastructure.repositories;

import com.mss301.authservice.domain.EmailVerification;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmailVerificationRepository extends JpaRepository<EmailVerification, Long> {

    Optional<EmailVerification> findTopByUserAccountIdAndVerifiedFalseOrderByCreatedAtDesc(Long accountId);
}
