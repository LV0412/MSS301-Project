package com.mss301.userservice.repository;

import com.mss301.userservice.entity.NutritionGoal;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NutritionGoalRepository extends JpaRepository<NutritionGoal, Long> {

    Optional<NutritionGoal> findByUserUserId(Long userId);

    boolean existsByUserUserId(Long userId);
}
