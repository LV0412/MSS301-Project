package com.mss301.userservice.repository;

import com.mss301.userservice.entity.MealPlanEntry;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MealPlanEntryRepository extends JpaRepository<MealPlanEntry, Long> {

    Optional<MealPlanEntry> findByEntryIdAndMealPlanMealPlanIdAndMealPlanUserUserId(
            Long entryId,
            Long mealPlanId,
            Long userId);
}
