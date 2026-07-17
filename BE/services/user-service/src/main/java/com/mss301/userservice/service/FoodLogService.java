package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateFoodLogRequest;
import com.mss301.userservice.dto.FoodLogResponse;
import com.mss301.userservice.dto.UpdateFoodLogRequest;
import com.mss301.userservice.entity.FoodLog;
import com.mss301.userservice.entity.MealType;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.FoodLogNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.FoodLogRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.util.PageableUtils;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class FoodLogService {

    private final FoodLogRepository foodLogRepository;
    private final UserRepository userRepository;

    public FoodLogResponse createFoodLog(Long userId, CreateFoodLogRequest request) {
        User user = findUser(userId);

        FoodLog foodLog = FoodLog.builder()
                .user(user)
                .recipeId(request.recipeId())
                .quantity(request.quantity())
                .mealType(request.mealType())
                .logDate(request.logDate())
                .build();

        return toResponse(foodLogRepository.save(foodLog));
    }

    @Transactional(readOnly = true)
    public Page<FoodLogResponse> getFoodLogHistory(
            Long userId,
            LocalDate date,
            MealType mealType,
            Pageable pageable) {
        findUser(userId);

        Specification<FoodLog> specification = belongsToUser(userId)
                .and(hasDate(date))
                .and(hasMealType(mealType));

        return foodLogRepository.findAll(specification, PageableUtils.normalizeSort(pageable, "logDate"))
                .map(this::toResponse);
    }

    public FoodLogResponse updateFoodLog(Long userId, Long logId, UpdateFoodLogRequest request) {
        FoodLog foodLog = findFoodLog(userId, logId);

        foodLog.setRecipeId(request.recipeId());
        foodLog.setQuantity(request.quantity());
        foodLog.setMealType(request.mealType());
        foodLog.setLogDate(request.logDate());

        return toResponse(foodLogRepository.save(foodLog));
    }

    public void deleteFoodLog(Long userId, Long logId) {
        FoodLog foodLog = findFoodLog(userId, logId);
        foodLogRepository.delete(foodLog);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private FoodLog findFoodLog(Long userId, Long logId) {
        return foodLogRepository.findByLogIdAndUserUserId(logId, userId)
                .orElseThrow(() -> new FoodLogNotFoundException(logId, userId));
    }

    private Specification<FoodLog> belongsToUser(Long userId) {
        return (root, query, criteriaBuilder) -> criteriaBuilder.equal(root.get("user").get("userId"), userId);
    }

    private Specification<FoodLog> hasDate(LocalDate date) {
        return (root, query, criteriaBuilder) -> date == null
                ? criteriaBuilder.conjunction()
                : criteriaBuilder.equal(root.get("logDate"), date);
    }

    private Specification<FoodLog> hasMealType(MealType mealType) {
        return (root, query, criteriaBuilder) -> mealType == null
                ? criteriaBuilder.conjunction()
                : criteriaBuilder.equal(root.get("mealType"), mealType);
    }

    private FoodLogResponse toResponse(FoodLog foodLog) {
        return FoodLogResponse.builder()
                .logId(foodLog.getLogId())
                .userId(foodLog.getUser().getUserId())
                .recipeId(foodLog.getRecipeId())
                .quantity(foodLog.getQuantity())
                .mealType(foodLog.getMealType())
                .logDate(foodLog.getLogDate())
                .build();
    }
}
