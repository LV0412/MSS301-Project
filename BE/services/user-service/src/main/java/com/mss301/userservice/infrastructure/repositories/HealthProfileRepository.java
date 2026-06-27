package com.mss301.userservice.infrastructure.repositories;

import com.mss301.userservice.domain.HealthProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HealthProfileRepository extends JpaRepository<HealthProfile, Long> {

    Optional<HealthProfile> findByUserUserId(Long userId);

    boolean existsByUserUserId(Long userId);
}
