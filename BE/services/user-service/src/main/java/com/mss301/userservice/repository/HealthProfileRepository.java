package com.mss301.userservice.repository;

import com.mss301.userservice.entity.HealthProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HealthProfileRepository extends JpaRepository<HealthProfile, Long> {

    Optional<HealthProfile> findByUserUserId(Long userId);

    boolean existsByUserUserId(Long userId);
}
