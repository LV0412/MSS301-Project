package com.mss301.authservice.repository;

import com.mss301.authservice.entity.EmailVerification;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmailVerificationRepository extends JpaRepository<EmailVerification, Long> {

    Optional<EmailVerification> findFirstByUserAccountAccountIdAndConsumedAtIsNullOrderByCreatedAtDesc(Long accountId);
}
