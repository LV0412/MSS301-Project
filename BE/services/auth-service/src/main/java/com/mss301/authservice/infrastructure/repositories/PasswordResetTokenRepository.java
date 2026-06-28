package com.mss301.authservice.infrastructure.repositories;

import com.mss301.authservice.domain.PasswordResetToken;
import java.time.LocalDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    Optional<PasswordResetToken> findByTokenHash(String tokenHash);

    long countByUserAccountIdAndCreatedAtAfter(Long accountId, LocalDateTime createdAt);
}
