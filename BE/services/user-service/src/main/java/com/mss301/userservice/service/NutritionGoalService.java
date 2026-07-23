package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalPreviewResponse;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.UpdateNutritionGoalRequest;

public interface NutritionGoalService {

    NutritionGoalResponse createNutritionGoal(Long userId, CreateNutritionGoalRequest request);

    NutritionGoalResponse getNutritionGoal(Long userId);

    NutritionGoalResponse updateNutritionGoal(Long userId, UpdateNutritionGoalRequest request);

    NutritionGoalPreviewResponse previewNutritionGoal(Long userId, UpdateNutritionGoalRequest request);

    void deleteNutritionGoal(Long userId);
}
