package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.UpdateNutritionGoalRequest;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.NutritionGoalAlreadyExistsException;
import com.mss301.userservice.exception.NutritionGoalNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class NutritionGoalService {

    private final NutritionGoalRepository nutritionGoalRepository;
    private final UserRepository userRepository;

    public NutritionGoalResponse createNutritionGoal(Long userId, CreateNutritionGoalRequest request) {
        if (nutritionGoalRepository.existsByUserUserId(userId)) {
            throw new NutritionGoalAlreadyExistsException(userId);
        }

        User user = findUser(userId);
        NutritionGoal nutritionGoal = NutritionGoal.builder()
                .user(user)
                .goalType(request.goalType())
                .targetWeight(request.targetWeight())
                .durationWeeks(request.durationWeeks())
                .weeklyRateKg(request.weeklyRateKg())
                .calories(request.calories())
                .protein(request.protein())
                .carbs(request.carbs())
                .fat(request.fat())
                .build();

        return toResponse(nutritionGoalRepository.save(nutritionGoal));
    }

    @Transactional(readOnly = true)
    public NutritionGoalResponse getNutritionGoal(Long userId) {
        return toResponse(findNutritionGoal(userId));
    }

    public NutritionGoalResponse updateNutritionGoal(Long userId, UpdateNutritionGoalRequest request) {
        NutritionGoal nutritionGoal = findNutritionGoal(userId);

        if (request.goalType() != null) {
            nutritionGoal.setGoalType(request.goalType());
        }
        if (request.targetWeight() != null) {
            nutritionGoal.setTargetWeight(request.targetWeight());
        }
        if (request.durationWeeks() != null) {
            nutritionGoal.setDurationWeeks(request.durationWeeks());
        }
        if (request.weeklyRateKg() != null) {
            nutritionGoal.setWeeklyRateKg(request.weeklyRateKg());
        }
        if (request.calories() != null) {
            nutritionGoal.setCalories(request.calories());
        }
        if (request.protein() != null) {
            nutritionGoal.setProtein(request.protein());
        }
        if (request.carbs() != null) {
            nutritionGoal.setCarbs(request.carbs());
        }
        if (request.fat() != null) {
            nutritionGoal.setFat(request.fat());
        }

        return toResponse(nutritionGoalRepository.save(nutritionGoal));
    }

    public void deleteNutritionGoal(Long userId) {
        NutritionGoal nutritionGoal = findNutritionGoal(userId);
        nutritionGoalRepository.delete(nutritionGoal);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private NutritionGoal findNutritionGoal(Long userId) {
        return nutritionGoalRepository.findByUserUserId(userId)
                .orElseThrow(() -> new NutritionGoalNotFoundException(userId));
    }

    private NutritionGoalResponse toResponse(NutritionGoal nutritionGoal) {
        return NutritionGoalResponse.builder()
                .goalId(nutritionGoal.getGoalId())
                .userId(nutritionGoal.getUser().getUserId())
                .goalType(nutritionGoal.getGoalType())
                .targetWeight(nutritionGoal.getTargetWeight())
                .durationWeeks(nutritionGoal.getDurationWeeks())
                .weeklyRateKg(nutritionGoal.getWeeklyRateKg())
                .calories(nutritionGoal.getCalories())
                .protein(nutritionGoal.getProtein())
                .carbs(nutritionGoal.getCarbs())
                .fat(nutritionGoal.getFat())
                .build();
    }
}
