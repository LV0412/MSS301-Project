package com.mss301.userservice.repository;

import com.mss301.userservice.entity.MealPlan;
import com.mss301.userservice.entity.MealPlanStatus;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MealPlanRepository extends JpaRepository<MealPlan, Long> {

    Optional<MealPlan> findTopByUserUserIdAndPlanDateOrderByCreatedAtDesc(Long userId, LocalDate planDate);

    Optional<MealPlan> findByMealPlanIdAndUserUserId(Long mealPlanId, Long userId);

    List<MealPlan> findAllByUserUserIdAndStatus(Long userId, MealPlanStatus status);
}
