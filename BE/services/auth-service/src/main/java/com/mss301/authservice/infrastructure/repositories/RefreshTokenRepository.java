package com.mss301.authservice.infrastructure.repositories;

import com.mss301.authservice.domain.RefreshToken;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    Optional<RefreshToken> findByTokenHash(String tokenHash);

    List<RefreshToken> findAllByUserAccountIdAndRevokedFalse(Long accountId);

    void deleteAllByUserAccountId(Long accountId);
}
