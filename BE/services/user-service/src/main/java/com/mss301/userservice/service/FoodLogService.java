package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateFoodLogRequest;
import com.mss301.userservice.dto.FoodLogResponse;
import com.mss301.userservice.dto.UpdateFoodLogRequest;
import com.mss301.userservice.entity.MealType;
import java.time.LocalDate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface FoodLogService {

    FoodLogResponse createFoodLog(Long userId, CreateFoodLogRequest request);

    Page<FoodLogResponse> getFoodLogHistory(
            Long userId,
            LocalDate date,
            MealType mealType,
            Pageable pageable);

    FoodLogResponse updateFoodLog(Long userId, Long logId, UpdateFoodLogRequest request);

    void deleteFoodLog(Long userId, Long logId);
}
