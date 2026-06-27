package com.mss301.userservice.infrastructure.repositories;

import com.mss301.userservice.domain.NutritionGoal;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NutritionGoalRepository extends JpaRepository<NutritionGoal, Long> {

    Optional<NutritionGoal> findByUserUserId(Long userId);

    boolean existsByUserUserId(Long userId);
}
