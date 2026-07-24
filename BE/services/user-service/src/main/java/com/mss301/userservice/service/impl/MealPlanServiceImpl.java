package com.mss301.userservice.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mss301.userservice.client.AiGeneratedMealPlanEntry;
import com.mss301.userservice.client.AiGeneratedMealPlanResponse;
import com.mss301.userservice.client.AiMealPlanClient;
import com.mss301.userservice.dto.MealPlanEntryResponse;
import com.mss301.userservice.dto.MealPlanResponse;
import com.mss301.userservice.dto.SwapMealPlanEntryRequest;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.MealPlan;
import com.mss301.userservice.entity.MealPlanEntry;
import com.mss301.userservice.entity.MealPlanStatus;
import com.mss301.userservice.entity.MealType;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.HealthProfileNotFoundException;
import com.mss301.userservice.exception.InvalidNutritionGoalException;
import com.mss301.userservice.exception.NutritionGoalNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.MealPlanEntryRepository;
import com.mss301.userservice.repository.MealPlanRepository;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.service.MealPlanService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
@Transactional
public class MealPlanServiceImpl implements MealPlanService {

    private static final TypeReference<List<String>> STRING_LIST = new TypeReference<>() {
    };

    private final MealPlanRepository mealPlanRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final UserRepository userRepository;
    private final HealthProfileRepository healthProfileRepository;
    private final NutritionGoalRepository nutritionGoalRepository;
    private final AiMealPlanClient aiMealPlanClient;
    private final ObjectMapper objectMapper;

    public MealPlanResponse generateMealPlan(Long userId, LocalDate date) {
        User user = findUser(userId);
        NutritionGoal nutritionGoal = requireConfiguredGoal(userId);
        AiGeneratedMealPlanResponse generated = aiMealPlanClient.generateMealPlan(userId, date);

        MealPlan mealPlan = MealPlan.builder()
                .user(user)
                .nutritionGoal(nutritionGoal)
                .nutritionGoalVersion(nutritionGoal.getGoalVersion())
                .planDate(date)
                .title(generated.title())
                .status(MealPlanStatus.DRAFT)
                .matchScore(generated.matchScore())
                .warningsJson(toJson(generated.warnings()))
                .build();
        for (AiGeneratedMealPlanEntry generatedEntry : generated.entries()) {
            mealPlan.addEntry(toEntry(generatedEntry));
        }
        return toResponse(mealPlanRepository.save(mealPlan));
    }

    @Transactional(readOnly = true)
    public MealPlanResponse getMealPlan(Long userId, LocalDate date) {
        MealPlan mealPlan = mealPlanRepository.findTopByUserUserIdAndPlanDateOrderByCreatedAtDesc(userId, date)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan not found"));
        return toResponse(mealPlan);
    }

    public MealPlanResponse swapEntry(Long userId, Long mealPlanId, Long entryId, SwapMealPlanEntryRequest request) {
        MealPlan mealPlan = findDraftMealPlan(userId, mealPlanId);
        MealPlanEntry entry = mealPlanEntryRepository
                .findByEntryIdAndMealPlanMealPlanIdAndMealPlanUserUserId(entryId, mealPlanId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan entry not found"));

        AiGeneratedMealPlanEntry candidate = aiMealPlanClient.buildSwapCandidate(
                userId,
                entry.getMealType().name().toLowerCase(),
                request.newRecipeId());
        applyEntrySnapshot(entry, candidate);
        entry.setManuallySwapped(true);
        mealPlan.setMatchScore(calculateMatchScore(mealPlan, mealPlan.getNutritionGoal()));
        return toResponse(mealPlanRepository.save(mealPlan));
    }

    public MealPlanResponse finalizeMealPlan(Long userId, Long mealPlanId) {
        MealPlan mealPlan = findDraftMealPlan(userId, mealPlanId);
        mealPlan.setStatus(MealPlanStatus.FINALIZED);
        mealPlan.setFinalizedAt(LocalDateTime.now());
        return toResponse(mealPlanRepository.save(mealPlan));
    }

    private MealPlan findDraftMealPlan(Long userId, Long mealPlanId) {
        MealPlan mealPlan = mealPlanRepository.findByMealPlanIdAndUserUserId(mealPlanId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan not found"));
        if (mealPlan.getStatus() != MealPlanStatus.DRAFT) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Only DRAFT meal plans can be changed");
        }
        return mealPlan;
    }

    private NutritionGoal requireConfiguredGoal(Long userId) {
        findCompleteHealthProfile(userId);
        NutritionGoal nutritionGoal = nutritionGoalRepository.findByUserUserId(userId)
                .orElseThrow(() -> new NutritionGoalNotFoundException(userId));
        if (!nutritionGoal.isGoalConfigured()) {
            throw new InvalidNutritionGoalException("Nutrition goal must be configured before generating a meal plan");
        }
        return nutritionGoal;
    }

    private HealthProfile findCompleteHealthProfile(Long userId) {
        HealthProfile healthProfile = healthProfileRepository.findByUserUserId(userId)
                .orElseThrow(() -> new HealthProfileNotFoundException(userId));
        if (healthProfile.getHeight() == null
                || healthProfile.getWeight() == null
                || healthProfile.getActivityLevel() == null) {
            throw new InvalidNutritionGoalException("Complete health profile is required before generating a meal plan");
        }
        return healthProfile;
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private MealPlanEntry toEntry(AiGeneratedMealPlanEntry generatedEntry) {
        return MealPlanEntry.builder()
                .recipeId(generatedEntry.recipeId())
                .mealType(MealType.valueOf(generatedEntry.mealType().toUpperCase()))
                .scheduledTime(generatedEntry.scheduledTime())
                .recipeName(generatedEntry.recipeName())
                .targetCaloriesForSlot(generatedEntry.targetCaloriesForSlot())
                .actualCalories(generatedEntry.actualCalories())
                .actualProtein(generatedEntry.actualProtein())
                .actualCarbs(generatedEntry.actualCarbs())
                .actualFat(generatedEntry.actualFat())
                .imageUrl(generatedEntry.imageUrl())
                .suitabilityScore(generatedEntry.suitabilityScore())
                .reason(generatedEntry.reason())
                .warningsJson(toJson(generatedEntry.warnings()))
                .manuallySwapped(generatedEntry.manuallySwapped())
                .build();
    }

    private void applyEntrySnapshot(MealPlanEntry entry, AiGeneratedMealPlanEntry candidate) {
        entry.setRecipeId(candidate.recipeId());
        entry.setScheduledTime(candidate.scheduledTime());
        entry.setRecipeName(candidate.recipeName());
        entry.setTargetCaloriesForSlot(candidate.targetCaloriesForSlot());
        entry.setActualCalories(candidate.actualCalories());
        entry.setActualProtein(candidate.actualProtein());
        entry.setActualCarbs(candidate.actualCarbs());
        entry.setActualFat(candidate.actualFat());
        entry.setImageUrl(candidate.imageUrl());
        entry.setSuitabilityScore(candidate.suitabilityScore());
        entry.setReason(candidate.reason());
        entry.setWarningsJson(toJson(candidate.warnings()));
    }

    private MealPlanResponse toResponse(MealPlan mealPlan) {
        String status = mealPlan.getStatus().name();
        if (mealPlan.getStatus() == MealPlanStatus.DRAFT && isOutdated(mealPlan)) {
            status = MealPlanStatus.OUTDATED.name();
        }
        return MealPlanResponse.builder()
                .mealPlanId(mealPlan.getMealPlanId())
                .userId(mealPlan.getUser().getUserId())
                .nutritionGoalId(mealPlan.getNutritionGoal().getGoalId())
                .nutritionGoalVersion(mealPlan.getNutritionGoalVersion())
                .planDate(mealPlan.getPlanDate())
                .title(mealPlan.getTitle())
                .status(status)
                .matchScore(mealPlan.getMatchScore())
                .warnings(fromJson(mealPlan.getWarningsJson()))
                .entries(mealPlan.getEntries().stream().map(this::toEntryResponse).toList())
                .build();
    }

    private MealPlanEntryResponse toEntryResponse(MealPlanEntry entry) {
        return MealPlanEntryResponse.builder()
                .entryId(entry.getEntryId())
                .recipeId(entry.getRecipeId())
                .mealType(entry.getMealType())
                .scheduledTime(entry.getScheduledTime())
                .recipeName(entry.getRecipeName())
                .targetCaloriesForSlot(entry.getTargetCaloriesForSlot())
                .actualCalories(entry.getActualCalories())
                .actualProtein(entry.getActualProtein())
                .actualCarbs(entry.getActualCarbs())
                .actualFat(entry.getActualFat())
                .imageUrl(entry.getImageUrl())
                .suitabilityScore(entry.getSuitabilityScore())
                .reason(entry.getReason())
                .warnings(fromJson(entry.getWarningsJson()))
                .manuallySwapped(entry.isManuallySwapped())
                .build();
    }

    private boolean isOutdated(MealPlan mealPlan) {
        return nutritionGoalRepository.findByUserUserId(mealPlan.getUser().getUserId())
                .map(current -> !current.getGoalId().equals(mealPlan.getNutritionGoal().getGoalId())
                        || !current.getGoalVersion().equals(mealPlan.getNutritionGoalVersion()))
                .orElse(true);
    }

    private BigDecimal calculateMatchScore(MealPlan mealPlan, NutritionGoal nutritionGoal) {
        return calorieScore(total(mealPlan, "calories"), nutritionGoal.getDailyCaloriesGoal())
                .add(macroScore(total(mealPlan, "protein"), nutritionGoal.getProtein()))
                .add(macroScore(total(mealPlan, "carbs"), nutritionGoal.getCarbs()))
                .add(macroScore(total(mealPlan, "fat"), nutritionGoal.getFat()))
                .divide(BigDecimal.valueOf(4), 2, RoundingMode.HALF_UP);
    }

    private BigDecimal total(MealPlan mealPlan, String field) {
        int total = mealPlan.getEntries().stream()
                .mapToInt(entry -> switch (field) {
                    case "calories" -> entry.getActualCalories();
                    case "protein" -> entry.getActualProtein();
                    case "carbs" -> entry.getActualCarbs();
                    case "fat" -> entry.getActualFat();
                    default -> 0;
                })
                .sum();
        return BigDecimal.valueOf(total);
    }

    private BigDecimal macroScore(BigDecimal actual, BigDecimal target) {
        if (target == null || target.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.valueOf(100);
        }
        BigDecimal tolerance = BigDecimal.valueOf(5);
        BigDecimal difference = actual.subtract(target).abs().subtract(tolerance).max(BigDecimal.ZERO);
        BigDecimal differenceRatio = difference.divide(target, 4, RoundingMode.HALF_UP);
        return BigDecimal.valueOf(100).subtract(differenceRatio.multiply(BigDecimal.valueOf(100)))
                .max(BigDecimal.ZERO)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal calorieScore(BigDecimal actual, BigDecimal target) {
        if (target == null || target.compareTo(BigDecimal.ZERO) == 0) {
            return BigDecimal.valueOf(100);
        }
        BigDecimal allowedDifference = target.multiply(BigDecimal.valueOf(0.10));
        BigDecimal difference = actual.subtract(target).abs().subtract(allowedDifference).max(BigDecimal.ZERO);
        BigDecimal differenceRatio = difference.divide(target, 4, RoundingMode.HALF_UP);
        return BigDecimal.valueOf(100).subtract(differenceRatio.multiply(BigDecimal.valueOf(100)))
                .max(BigDecimal.ZERO)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private String toJson(List<String> values) {
        try {
            return objectMapper.writeValueAsString(values == null ? List.of() : values);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Could not serialize meal plan warnings", exception);
        }
    }

    private List<String> fromJson(String json) {
        try {
            return objectMapper.readValue(json == null ? "[]" : json, STRING_LIST);
        } catch (JsonProcessingException exception) {
            return List.of();
        }
    }
}
