package com.mss301.authservice.seed;

import com.mss301.authservice.entity.AccountStatus;
import com.mss301.authservice.entity.AuthProvider;
import com.mss301.authservice.entity.UserAccount;
import com.mss301.authservice.repository.UserAccountRepository;
import com.mss301.authservice.seed.AuthSeedDataFactory.SeedAccount;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "auth.seed", name = "enabled", havingValue = "true")
public class AuthDataSeeder implements CommandLineRunner {

    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        int createdAccounts = 0;
        int skippedAccounts = 0;

        for (SeedAccount seedAccount : AuthSeedDataFactory.accounts()) {
            if (userAccountRepository.existsByEmailIgnoreCase(seedAccount.email())) {
                skippedAccounts++;
                continue;
            }

            userAccountRepository.save(UserAccount.builder()
                    .email(seedAccount.email())
                    .passwordHash(passwordEncoder.encode(AuthSeedDataFactory.TEST_PASSWORD))
                    .fullName(seedAccount.fullName())
                    .role(seedAccount.role())
                    .status(AccountStatus.ACTIVE)
                    .emailVerified(true)
                    .provider(AuthProvider.LOCAL)
                    .failedLoginAttempts(0)
                    .build());
            createdAccounts++;
        }

        log.info(
                "Auth seed completed. createdAccounts={}, skippedAccounts={}, password={}",
                createdAccounts,
                skippedAccounts,
                AuthSeedDataFactory.TEST_PASSWORD);
    }
}
