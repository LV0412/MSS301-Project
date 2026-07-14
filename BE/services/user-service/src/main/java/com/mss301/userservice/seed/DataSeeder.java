package com.mss301.userservice.seed;

import com.mss301.userservice.entity.DietPreference;
import com.mss301.userservice.entity.Favorite;
import com.mss301.userservice.entity.FoodLog;
import com.mss301.userservice.entity.HealthProfile;
import com.mss301.userservice.entity.NutritionGoal;
import com.mss301.userservice.entity.User;
import com.mss301.userservice.entity.UserAllergy;
import com.mss301.userservice.repository.DietPreferenceRepository;
import com.mss301.userservice.repository.FavoriteRepository;
import com.mss301.userservice.repository.FoodLogRepository;
import com.mss301.userservice.repository.HealthProfileRepository;
import com.mss301.userservice.repository.NutritionGoalRepository;
import com.mss301.userservice.repository.UserAllergyRepository;
import com.mss301.userservice.repository.UserRepository;
import com.mss301.userservice.seed.SeedDataFactory.SeedUser;
import java.math.BigDecimal;
import java.math.RoundingMode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "app.seed", name = "enabled", havingValue = "true")
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final HealthProfileRepository healthProfileRepository;
    private final NutritionGoalRepository nutritionGoalRepository;
    private final DietPreferenceRepository dietPreferenceRepository;
    private final UserAllergyRepository userAllergyRepository;
    private final FavoriteRepository favoriteRepository;
    private final FoodLogRepository foodLogRepository;

    @Override
    @Transactional
    public void run(String... args) {
        int createdUsers = 0;
        int skippedUsers = 0;

        for (SeedUser seedUser : SeedDataFactory.users()) {
            if (userRepository.existsByEmailIgnoreCase(seedUser.email())) {
                skippedUsers++;
                continue;
            }

            User user = createUser(seedUser);
            createHealthProfile(user, seedUser);
            createNutritionGoal(user, seedUser);
            createDietPreferences(user, seedUser);
            createUserAllergies(user, seedUser);
            createFavorites(user, seedUser);
            createFoodLogs(user, seedUser);
            createdUsers++;
        }

        log.info("User service seed completed. createdUsers={}, skippedUsers={}", createdUsers, skippedUsers);
    }

    private User createUser(SeedUser seedUser) {
        User user = User.builder()
                .email(seedUser.email())
                .passwordHash(seedUser.passwordHash())
                .fullName(seedUser.fullName())
                .dob(seedUser.dob())
                .gender(seedUser.gender())
                .build();
        return userRepository.save(user);
    }

    private void createHealthProfile(User user, SeedUser seedUser) {
        HealthProfile healthProfile = HealthProfile.builder()
                .user(user)
                .height(seedUser.healthProfile().height())
                .weight(seedUser.healthProfile().weight())
                .activityLevel(seedUser.healthProfile().activityLevel())
                .bmi(calculateBmi(seedUser.healthProfile().height(), seedUser.healthProfile().weight()))
                .build();
        healthProfileRepository.save(healthProfile);
    }

    private void createNutritionGoal(User user, SeedUser seedUser) {
        NutritionGoal nutritionGoal = NutritionGoal.builder()
                .user(user)
                .calories(seedUser.nutritionGoal().calories())
                .protein(seedUser.nutritionGoal().protein())
                .carbs(seedUser.nutritionGoal().carbs())
                .fat(seedUser.nutritionGoal().fat())
                .build();
        nutritionGoalRepository.save(nutritionGoal);
    }

    private void createDietPreferences(User user, SeedUser seedUser) {
        dietPreferenceRepository.saveAll(seedUser.dietTypes().stream()
                .map(dietType -> DietPreference.builder()
                        .user(user)
                        .dietType(dietType)
                        .build())
                .toList());
    }

    private void createUserAllergies(User user, SeedUser seedUser) {
        userAllergyRepository.saveAll(seedUser.allergies().stream()
                .map(allergy -> UserAllergy.builder()
                        .user(user)
                        .allergenId(allergy.allergenId())
                        .severity(allergy.severity())
                        .build())
                .toList());
    }

    private void createFavorites(User user, SeedUser seedUser) {
        favoriteRepository.saveAll(seedUser.favoriteRecipeIds().stream()
                .map(recipeId -> Favorite.builder()
                        .user(user)
                        .recipeId(recipeId)
                        .build())
                .toList());
    }

    private void createFoodLogs(User user, SeedUser seedUser) {
        foodLogRepository.saveAll(seedUser.foodLogs().stream()
                .map(foodLog -> FoodLog.builder()
                        .user(user)
                        .recipeId(foodLog.recipeId())
                        .quantity(foodLog.quantity())
                        .mealType(foodLog.mealType())
                        .logDate(foodLog.logDate())
                        .build())
                .toList());
    }

    private BigDecimal calculateBmi(BigDecimal height, BigDecimal weight) {
        BigDecimal heightInMeters = height.divide(BigDecimal.valueOf(100), 6, RoundingMode.HALF_UP);
        return weight.divide(heightInMeters.pow(2), 2, RoundingMode.HALF_UP);
    }
}
