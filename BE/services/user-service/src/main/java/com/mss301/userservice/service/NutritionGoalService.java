package com.mss301.userservice.service;

import com.mss301.userservice.dto.CreateNutritionGoalRequest;
import com.mss301.userservice.dto.NutritionGoalResponse;
import com.mss301.userservice.dto.UpdateNutritionGoalRequest;
import com.mss301.userservice.entity.ActivityLevel;
import com.mss301.userservice.entity.Gender;
import com.mss301.userservice.entity.GoalType;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.exception.HealthProfileNotFoundException;
import com.mss301.userservice.exception.InvalidNutritionGoalException;
import com.mss301.userservice.exception.NutritionGoalAlreadyExistsException;
import com.mss301.userservice.exception.NutritionGoalNotFoundException;
import com.mss301.userservice.exception.UserNotFoundException;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserRepository;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class NutritionGoalService {

    private static final BigDecimal KCAL_PER_KG_WEIGHT_CHANGE = BigDecimal.valueOf(7700);
    private static final BigDecimal MIN_SAFE_WEEKLY_RATE_KG = BigDecimal.valueOf(0.25);
    private static final BigDecimal MAX_SAFE_WEEKLY_RATE_KG = BigDecimal.valueOf(1.0);
    private static final BigDecimal WEEKLY_RATE_TOLERANCE_KG = BigDecimal.valueOf(0.01);
    private static final BigDecimal MIN_ABSOLUTE_TARGET_BMI = BigDecimal.valueOf(16);
    private static final BigDecimal MIN_WARNING_TARGET_BMI = BigDecimal.valueOf(18.5);
    private static final BigDecimal MAX_WARNING_TARGET_BMI = BigDecimal.valueOf(30);
    private static final BigDecimal MAX_ABSOLUTE_TARGET_BMI = BigDecimal.valueOf(35);
    private static final BigDecimal MAINTAIN_WEIGHT_TOLERANCE_KG = BigDecimal.valueOf(0.05);

    private final NutritionGoalRepository nutritionGoalRepository;
    private final UserRepository userRepository;
    private final HealthProfileRepository healthProfileRepository;

    public NutritionGoalResponse createNutritionGoal(Long userId, CreateNutritionGoalRequest request) {
        if (nutritionGoalRepository.existsByUserUserId(userId)) {
            throw new NutritionGoalAlreadyExistsException(userId);
        }

        User user = findUser(userId);
        HealthProfile healthProfile = findHealthProfile(userId);
        NutritionGoalEvaluation evaluation = evaluateGoal(
                user,
                healthProfile,
                request.goalType(),
                request.targetWeight(),
                request.durationWeeks(),
                request.weeklyRateKg(),
                request.dailyCaloriesGoal(),
                true);

        NutritionGoal nutritionGoal = NutritionGoal.builder()
                .user(user)
                .goalType(request.goalType())
                .targetWeight(request.targetWeight())
                .durationWeeks(request.durationWeeks())
                .weeklyRateKg(evaluation.weeklyRateKg())
                .recommendedCalories(evaluation.recommendedCalories())
                .dailyCaloriesGoal(evaluation.dailyCaloriesGoal())
                .protein(request.protein())
                .carbs(request.carbs())
                .fat(request.fat())
                .build();

        return toResponse(nutritionGoalRepository.save(nutritionGoal), evaluation.warnings());
    }

    @Transactional(readOnly = true)
    public NutritionGoalResponse getNutritionGoal(Long userId) {
        NutritionGoal nutritionGoal = findNutritionGoal(userId);
        return toResponse(nutritionGoal, buildTargetBmiWarnings(nutritionGoal.getTargetWeight(), findHealthProfile(userId)));
    }

    public NutritionGoalResponse updateNutritionGoal(Long userId, UpdateNutritionGoalRequest request) {
        NutritionGoal nutritionGoal = findNutritionGoal(userId);
        User user = nutritionGoal.getUser();
        HealthProfile healthProfile = findHealthProfile(userId);

        GoalType goalType = request.goalType() != null ? request.goalType() : nutritionGoal.getGoalType();
        BigDecimal targetWeight = request.targetWeight() != null
                ? request.targetWeight()
                : nutritionGoal.getTargetWeight();
        Integer durationWeeks = request.durationWeeks() != null
                ? request.durationWeeks()
                : nutritionGoal.getDurationWeeks();
        BigDecimal weeklyRateKg = request.weeklyRateKg() != null
                ? request.weeklyRateKg()
                : nutritionGoal.getWeeklyRateKg();
        boolean planChanged = request.goalType() != null
                || request.targetWeight() != null
                || request.durationWeeks() != null
                || request.weeklyRateKg() != null;
        BigDecimal requestedDailyCaloriesGoal = request.dailyCaloriesGoal() != null
                ? request.dailyCaloriesGoal()
                : planChanged ? null : nutritionGoal.getDailyCaloriesGoal();
        NutritionGoalEvaluation evaluation = evaluateGoal(
                user,
                healthProfile,
                goalType,
                targetWeight,
                durationWeeks,
                weeklyRateKg,
                requestedDailyCaloriesGoal,
                planChanged);

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
            nutritionGoal.setWeeklyRateKg(evaluation.weeklyRateKg());
        }
        nutritionGoal.setRecommendedCalories(evaluation.recommendedCalories());
        nutritionGoal.setDailyCaloriesGoal(evaluation.dailyCaloriesGoal());
        if (request.protein() != null) {
            nutritionGoal.setProtein(request.protein());
        }
        if (request.carbs() != null) {
            nutritionGoal.setCarbs(request.carbs());
        }
        if (request.fat() != null) {
            nutritionGoal.setFat(request.fat());
        }

        return toResponse(nutritionGoalRepository.save(nutritionGoal), evaluation.warnings());
    }

    public void deleteNutritionGoal(Long userId) {
        NutritionGoal nutritionGoal = findNutritionGoal(userId);
        nutritionGoalRepository.delete(nutritionGoal);
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException(userId));
    }

    private HealthProfile findHealthProfile(Long userId) {
        return healthProfileRepository.findByUserUserId(userId)
                .orElseThrow(() -> new HealthProfileNotFoundException(userId));
    }

    private NutritionGoal findNutritionGoal(Long userId) {
        return nutritionGoalRepository.findByUserUserId(userId)
                .orElseThrow(() -> new NutritionGoalNotFoundException(userId));
    }

    private NutritionGoalResponse toResponse(NutritionGoal nutritionGoal, List<String> warnings) {
        return NutritionGoalResponse.builder()
                .goalId(nutritionGoal.getGoalId())
                .userId(nutritionGoal.getUser().getUserId())
                .goalType(nutritionGoal.getGoalType())
                .targetWeight(nutritionGoal.getTargetWeight())
                .durationWeeks(nutritionGoal.getDurationWeeks())
                .weeklyRateKg(nutritionGoal.getWeeklyRateKg())
                .recommendedCalories(nutritionGoal.getRecommendedCalories())
                .dailyCaloriesGoal(nutritionGoal.getDailyCaloriesGoal())
                .protein(nutritionGoal.getProtein())
                .carbs(nutritionGoal.getCarbs())
                .fat(nutritionGoal.getFat())
                .warnings(warnings)
                .build();
    }

    private NutritionGoalEvaluation evaluateGoal(
            User user,
            HealthProfile healthProfile,
            GoalType goalType,
            BigDecimal targetWeight,
            Integer durationWeeks,
            BigDecimal requestedWeeklyRateKg,
            BigDecimal requestedDailyCaloriesGoal,
            boolean defaultDailyCaloriesToRecommended) {
        validateRequiredProfile(user, healthProfile);
        validateGoalDirection(goalType, healthProfile.getWeight(), targetWeight);

        BigDecimal calculatedWeeklyRateKg = calculateWeeklyRate(healthProfile.getWeight(), targetWeight, durationWeeks);
        BigDecimal weeklyRateKg = validateWeeklyRate(goalType, calculatedWeeklyRateKg, requestedWeeklyRateKg);
        List<String> warnings = buildTargetBmiWarnings(targetWeight, healthProfile);

        BigDecimal bmr = calculateBmr(user, healthProfile);
        BigDecimal tdee = calculateTdee(bmr, healthProfile.getActivityLevel());
        BigDecimal recommendedCalories = calculateRecommendedCalories(
                goalType,
                tdee,
                healthProfile.getWeight(),
                targetWeight,
                durationWeeks);
        BigDecimal dailyCaloriesGoal = requestedDailyCaloriesGoal != null
                ? requestRounded(requestedDailyCaloriesGoal)
                : defaultDailyCaloriesToRecommended ? recommendedCalories : requestedDailyCaloriesGoal;

        if (dailyCaloriesGoal == null) {
            dailyCaloriesGoal = recommendedCalories;
        }
        if (dailyCaloriesGoal.compareTo(bmr) < 0) {
            throw new InvalidNutritionGoalException("Daily calories goal must not be lower than calculated BMR");
        }
        if (recommendedCalories.compareTo(bmr) < 0 && requestedDailyCaloriesGoal != null) {
            warnings.add("Recommended calories are below BMR; manual daily calories override was applied.");
        }

        return new NutritionGoalEvaluation(recommendedCalories, dailyCaloriesGoal, weeklyRateKg, warnings);
    }

    private void validateRequiredProfile(User user, HealthProfile healthProfile) {
        if (user.getDob() == null) {
            throw new InvalidNutritionGoalException("User date of birth is required to calculate nutrition goal");
        }
        if (user.getGender() == null) {
            throw new InvalidNutritionGoalException("User gender is required to calculate nutrition goal");
        }
        if (healthProfile.getHeight() == null
                || healthProfile.getWeight() == null
                || healthProfile.getActivityLevel() == null) {
            throw new InvalidNutritionGoalException("Complete health profile is required to calculate nutrition goal");
        }
    }

    private void validateGoalDirection(GoalType goalType, BigDecimal currentWeight, BigDecimal targetWeight) {
        int direction = targetWeight.compareTo(currentWeight);
        if (goalType == GoalType.LOSE_WEIGHT && direction >= 0) {
            throw new InvalidNutritionGoalException("Target weight must be lower than current weight for LOSE_WEIGHT");
        }
        if (goalType == GoalType.GAIN_WEIGHT && direction <= 0) {
            throw new InvalidNutritionGoalException("Target weight must be higher than current weight for GAIN_WEIGHT");
        }
        if (goalType == GoalType.MAINTAIN
                && currentWeight.subtract(targetWeight).abs().compareTo(MAINTAIN_WEIGHT_TOLERANCE_KG) > 0) {
            throw new InvalidNutritionGoalException("Target weight must match current weight for MAINTAIN");
        }
    }

    private BigDecimal calculateWeeklyRate(BigDecimal currentWeight, BigDecimal targetWeight, Integer durationWeeks) {
        return currentWeight.subtract(targetWeight).abs()
                .divide(BigDecimal.valueOf(durationWeeks), 4, RoundingMode.HALF_UP);
    }

    private BigDecimal validateWeeklyRate(
            GoalType goalType,
            BigDecimal calculatedWeeklyRateKg,
            BigDecimal requestedWeeklyRateKg) {
        if (goalType == GoalType.MAINTAIN) {
            if (requestedWeeklyRateKg.compareTo(BigDecimal.ZERO) != 0) {
                throw new InvalidNutritionGoalException("Weekly rate must be 0 kg/week for MAINTAIN");
            }
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }

        if (requestedWeeklyRateKg.compareTo(MIN_SAFE_WEEKLY_RATE_KG) < 0
                || requestedWeeklyRateKg.compareTo(MAX_SAFE_WEEKLY_RATE_KG) > 0) {
            throw new InvalidNutritionGoalException("Weekly rate must be between 0.25 and 1.0 kg/week");
        }

        BigDecimal rateDifference = requestedWeeklyRateKg.subtract(calculatedWeeklyRateKg).abs();
        if (rateDifference.compareTo(WEEKLY_RATE_TOLERANCE_KG) > 0) {
            throw new InvalidNutritionGoalException("Weekly rate must match target weight and duration weeks");
        }

        return calculatedWeeklyRateKg.setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateBmr(User user, HealthProfile healthProfile) {
        int age = Period.between(user.getDob(), LocalDate.now()).getYears();
        BigDecimal base = healthProfile.getWeight().multiply(BigDecimal.TEN)
                .add(healthProfile.getHeight().multiply(BigDecimal.valueOf(6.25)))
                .subtract(BigDecimal.valueOf(5L * age));

        if (user.getGender() == Gender.MALE) {
            return base.add(BigDecimal.valueOf(5)).setScale(2, RoundingMode.HALF_UP);
        }
        if (user.getGender() == Gender.FEMALE) {
            return base.subtract(BigDecimal.valueOf(161)).setScale(2, RoundingMode.HALF_UP);
        }

        BigDecimal maleBmr = base.add(BigDecimal.valueOf(5));
        BigDecimal femaleBmr = base.subtract(BigDecimal.valueOf(161));
        return maleBmr.add(femaleBmr)
                .divide(BigDecimal.valueOf(2), 2, RoundingMode.HALF_UP);
    }

    private BigDecimal calculateTdee(BigDecimal bmr, ActivityLevel activityLevel) {
        return bmr.multiply(activityFactor(activityLevel)).setScale(2, RoundingMode.HALF_UP);
    }

    private BigDecimal activityFactor(ActivityLevel activityLevel) {
        return switch (activityLevel) {
            case SEDENTARY -> BigDecimal.valueOf(1.2);
            case LIGHT -> BigDecimal.valueOf(1.375);
            case MODERATE -> BigDecimal.valueOf(1.55);
            case ACTIVE -> BigDecimal.valueOf(1.725);
            case VERY_ACTIVE -> BigDecimal.valueOf(1.9);
        };
    }

    private BigDecimal calculateRecommendedCalories(
            GoalType goalType,
            BigDecimal tdee,
            BigDecimal currentWeight,
            BigDecimal targetWeight,
            Integer durationWeeks) {
        if (goalType == GoalType.MAINTAIN) {
            return tdee.setScale(2, RoundingMode.HALF_UP);
        }

        BigDecimal dailyAdjustment = currentWeight.subtract(targetWeight).abs()
                .multiply(KCAL_PER_KG_WEIGHT_CHANGE)
                .divide(BigDecimal.valueOf(durationWeeks * 7L), 2, RoundingMode.HALF_UP);

        return switch (goalType) {
            case LOSE_WEIGHT -> tdee.subtract(dailyAdjustment).setScale(2, RoundingMode.HALF_UP);
            case GAIN_WEIGHT -> tdee.add(dailyAdjustment).setScale(2, RoundingMode.HALF_UP);
            case MAINTAIN -> tdee.setScale(2, RoundingMode.HALF_UP);
        };
    }

    private List<String> buildTargetBmiWarnings(BigDecimal targetWeight, HealthProfile healthProfile) {
        BigDecimal targetBmi = calculateBmi(targetWeight, healthProfile.getHeight());
        if (targetBmi.compareTo(MIN_ABSOLUTE_TARGET_BMI) < 0
                || targetBmi.compareTo(MAX_ABSOLUTE_TARGET_BMI) > 0) {
            throw new InvalidNutritionGoalException("Target BMI must be between 16 and 35");
        }

        List<String> warnings = new ArrayList<>();
        if (targetBmi.compareTo(MIN_WARNING_TARGET_BMI) < 0) {
            warnings.add("Target BMI is below 18.5; consider medical guidance before following this plan.");
        }
        if (targetBmi.compareTo(MAX_WARNING_TARGET_BMI) > 0) {
            warnings.add("Target BMI is above 30; consider medical guidance before following this plan.");
        }
        return warnings;
    }

    private BigDecimal calculateBmi(BigDecimal weight, BigDecimal heightCm) {
        BigDecimal heightM = heightCm.divide(BigDecimal.valueOf(100), 6, RoundingMode.HALF_UP);
        return weight.divide(heightM.pow(2), 2, RoundingMode.HALF_UP);
    }

    private BigDecimal requestRounded(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }

    private record NutritionGoalEvaluation(
            BigDecimal recommendedCalories,
            BigDecimal dailyCaloriesGoal,
            BigDecimal weeklyRateKg,
            List<String> warnings) {
    }
}
