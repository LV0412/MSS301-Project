package com.mss301.authservice.repository;

import com.mss301.authservice.entity.AuthProvider;
import com.mss301.authservice.entity.UserAccount;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserAccountRepository extends JpaRepository<UserAccount, Long> {

    boolean existsByEmailIgnoreCase(String email);

    Optional<UserAccount> findByEmailIgnoreCase(String email);

    Optional<UserAccount> findByProviderAndProviderId(AuthProvider provider, String providerId);
}
