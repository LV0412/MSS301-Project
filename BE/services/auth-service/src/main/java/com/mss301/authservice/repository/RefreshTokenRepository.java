package com.mss301.authservice.repository;

import com.mss301.authservice.entity.RefreshToken;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    List<RefreshToken> findByUserAccountAccountIdAndRevokedAtIsNull(Long accountId);

    List<RefreshToken> findByRevokedAtIsNull();
}
