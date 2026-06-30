package com.mss301.authservice.repository;

import com.mss301.authservice.entity.RefreshToken;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    List<RefreshToken> findByUserAccountAccountIdAndRevokedAtIsNull(Long accountId);

    Optional<RefreshToken> findByTokenIdAndRevokedAtIsNull(String tokenId);
}
