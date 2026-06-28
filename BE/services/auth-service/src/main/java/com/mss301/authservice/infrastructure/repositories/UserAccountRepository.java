package com.mss301.authservice.infrastructure.repositories;

import com.mss301.authservice.domain.AuthProvider;
import com.mss301.authservice.domain.UserAccount;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAccountRepository extends JpaRepository<UserAccount, Long> {

    boolean existsByEmailIgnoreCase(String email);

    Optional<UserAccount> findByEmailIgnoreCase(String email);

    Optional<UserAccount> findByProviderAndProviderId(AuthProvider provider, String providerId);
}
