package com.mss301.userservice.service;

import com.mss301.userservice.dto.MealPlanResponse;
import com.mss301.userservice.dto.SwapMealPlanEntryRequest;
import java.time.LocalDate;

public interface MealPlanService {

    MealPlanResponse generateMealPlan(Long userId, LocalDate date);

    MealPlanResponse getMealPlan(Long userId, LocalDate date);

    MealPlanResponse swapEntry(Long userId, Long mealPlanId, Long entryId, SwapMealPlanEntryRequest request);

    MealPlanResponse finalizeMealPlan(Long userId, Long mealPlanId);
}
