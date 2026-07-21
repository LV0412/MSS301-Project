package com.mss301.userservice.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.mss301.userservice.client.RecipeCatalogReferenceValidator;
import com.mss301.userservice.dto.CreateFoodLogRequest;
import com.mss301.userservice.dto.UpdateFoodLogRequest;
import com.mss301.userservice.entity.FoodLog;
import com.mss301.userservice.entity.MealType;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.repository.FoodLogRepository;
import com.mss301.userservice.repository.UserRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class FoodLogServiceTest {

    @Mock
    private FoodLogRepository foodLogRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RecipeCatalogReferenceValidator recipeCatalogReferenceValidator;

    @InjectMocks
    private FoodLogService foodLogService;

    @Test
    void createFoodLogVerifiesRecipeBeforeSaving() {
        Long userId = 7L;
        Long recipeId = 42L;
        User user = User.builder().userId(userId).build();
        CreateFoodLogRequest request = new CreateFoodLogRequest(
                recipeId,
                BigDecimal.ONE,
                MealType.LUNCH,
                LocalDate.of(2026, 7, 21));

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(foodLogRepository.save(any(FoodLog.class))).thenAnswer(invocation -> {
            FoodLog foodLog = invocation.getArgument(0);
            foodLog.setLogId(1L);
            return foodLog;
        });

        foodLogService.createFoodLog(userId, request);

        verify(recipeCatalogReferenceValidator).requireRecipeExists(recipeId);
        verify(foodLogRepository).save(any(FoodLog.class));
    }

    @Test
    void updateFoodLogVerifiesRecipeBeforeSaving() {
        Long userId = 7L;
        Long logId = 3L;
        Long recipeId = 99L;
        User user = User.builder().userId(userId).build();
        FoodLog existingFoodLog = FoodLog.builder()
                .logId(logId)
                .user(user)
                .recipeId(42L)
                .quantity(BigDecimal.ONE)
                .mealType(MealType.BREAKFAST)
                .logDate(LocalDate.of(2026, 7, 20))
                .build();
        UpdateFoodLogRequest request = new UpdateFoodLogRequest(
                recipeId,
                BigDecimal.TWO,
                MealType.DINNER,
                LocalDate.of(2026, 7, 21));

        when(foodLogRepository.findByLogIdAndUserUserId(logId, userId)).thenReturn(Optional.of(existingFoodLog));
        when(foodLogRepository.save(any(FoodLog.class))).thenAnswer(invocation -> invocation.getArgument(0));

        foodLogService.updateFoodLog(userId, logId, request);

        verify(recipeCatalogReferenceValidator).requireRecipeExists(recipeId);
        verify(foodLogRepository).save(existingFoodLog);
    }
}
