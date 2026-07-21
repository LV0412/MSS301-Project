package com.mss301.userservice.seed;

import com.mss301.userservice.entity.ActivityLevel;
import com.mss301.userservice.entity.AllergySeverity;
import com.mss301.userservice.entity.Gender;
import com.mss301.userservice.entity.GoalType;
import com.mss301.userservice.entity.MealType;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public final class SeedDataFactory {

    // Plain test password: Password@123
    private static final String PASSWORD_HASH = "$2a$10$8RnbbV3E/wtkJAq/9//8RunIpZS5Rf1sEWI.SD2vSHHbQikqfoOpO";

    private SeedDataFactory() {
    }

    public static List<SeedUser> users() {
        LocalDate firstLogDate = LocalDate.now().minusDays(29);

        return List.of(
                user(
                        "minh.nguyen.seed@example.com",
                        "Nguyen Minh",
                        LocalDate.of(2004, 3, 12),
                        Gender.MALE,
                        health("170", "65", ActivityLevel.MODERATE),
                        nutrition(GoalType.MAINTAIN, "65", 12, "0.00", "2500", "150", "300", "70"),
                        List.of("HIGH_PROTEIN", "NORMAL"),
                        List.of(allergy(1L, AllergySeverity.HIGH), allergy(7L, AllergySeverity.LOW)),
                        List.of(1L, 3L, 8L, 15L),
                        foodLogs(firstLogDate, new long[]{1, 3, 8, 12, 15}, false, false, true)),
                user(
                        "linh.tran.seed@example.com",
                        "Tran Linh",
                        LocalDate.of(1998, 8, 4),
                        Gender.FEMALE,
                        health("160", "80", ActivityLevel.SEDENTARY),
                        nutrition(GoalType.LOSE_WEIGHT, "68", 24, "0.50", "1500", "90", "150", "45"),
                        List.of("LOW_CARB", "WEIGHT_LOSS"),
                        List.of(allergy(2L, AllergySeverity.MEDIUM), allergy(4L, AllergySeverity.LOW)),
                        List.of(2L, 6L, 9L),
                        foodLogs(firstLogDate, new long[]{3, 6, 9, 11, 14}, false, true, false)),
                user(
                        "quang.le.seed@example.com",
                        "Le Quang",
                        LocalDate.of(1986, 11, 21),
                        Gender.MALE,
                        health("180", "90", ActivityLevel.VERY_ACTIVE),
                        nutrition(GoalType.GAIN_WEIGHT, "95", 20, "0.25", "3000", "170", "350", "90"),
                        List.of("HIGH_PROTEIN", "MAINTAIN"),
                        List.of(allergy(3L, AllergySeverity.LOW)),
                        List.of(2L, 4L, 10L, 15L),
                        foodLogs(firstLogDate, new long[]{2, 4, 10, 13, 15}, false, false, true)),
                user(
                        "mai.pham.seed@example.com",
                        "Pham Mai",
                        LocalDate.of(1994, 1, 18),
                        Gender.FEMALE,
                        health("155", "48", ActivityLevel.LIGHT),
                        nutrition(GoalType.MAINTAIN, "48", 12, "0.00", "1800", "80", "220", "55"),
                        List.of("VEGETARIAN", "LOW_FAT"),
                        List.of(allergy(5L, AllergySeverity.HIGH)),
                        List.of(3L, 7L, 12L),
                        foodLogs(firstLogDate, new long[]{3, 7, 8, 12, 14}, false, false, false)),
                user(
                        "huyen.vo.seed@example.com",
                        "Vo Huyen",
                        LocalDate.of(1958, 6, 2),
                        Gender.FEMALE,
                        health("158", "60", ActivityLevel.LIGHT),
                        nutrition(GoalType.MAINTAIN, "60", 12, "0.00", "1600", "70", "180", "50"),
                        List.of("LOW_SODIUM", "NORMAL"),
                        List.of(allergy(6L, AllergySeverity.MEDIUM)),
                        List.of(3L, 4L, 11L),
                        foodLogs(firstLogDate, new long[]{3, 4, 5, 11, 12}, false, false, false)),
                user(
                        "bao.do.seed@example.com",
                        "Do Bao",
                        LocalDate.of(2001, 12, 29),
                        Gender.MALE,
                        health("172", "78", ActivityLevel.SEDENTARY),
                        nutrition(GoalType.LOSE_WEIGHT, "72", 16, "0.38", "2200", "100", "260", "65"),
                        List.of("GLUTEN_FREE", "LOW_SUGAR"),
                        List.of(allergy(7L, AllergySeverity.HIGH)),
                        List.of(1L, 5L, 13L),
                        foodLogs(firstLogDate, new long[]{1, 5, 6, 10, 13}, true, false, false)),
                user(
                        "an.ngo.seed@example.com",
                        "Ngo An",
                        LocalDate.of(1999, 5, 9),
                        Gender.OTHER,
                        health("168", "58", ActivityLevel.ACTIVE),
                        nutrition(GoalType.GAIN_WEIGHT, "62", 16, "0.25", "2100", "95", "250", "60"),
                        List.of("VEGAN", "DAIRY_FREE"),
                        List.of(allergy(2L, AllergySeverity.HIGH), allergy(3L, AllergySeverity.MEDIUM)),
                        List.of(3L, 8L, 14L),
                        foodLogs(firstLogDate, new long[]{3, 8, 9, 12, 14}, false, false, true)),
                user(
                        "khoa.bui.seed@example.com",
                        "Bui Khoa",
                        LocalDate.of(1990, 9, 15),
                        Gender.MALE,
                        health("176", "72", ActivityLevel.ACTIVE),
                        nutrition(GoalType.MAINTAIN, "72", 12, "0.00", "2600", "150", "300", "75"),
                        List.of("KETO", "HIGH_PROTEIN"),
                        List.of(allergy(4L, AllergySeverity.MEDIUM)),
                        List.of(2L, 4L, 15L),
                        foodLogs(firstLogDate, new long[]{2, 4, 6, 10, 15}, false, false, true)),
                user(
                        "thao.dang.seed@example.com",
                        "Dang Thao",
                        LocalDate.of(1982, 2, 25),
                        Gender.FEMALE,
                        health("162", "68", ActivityLevel.MODERATE),
                        nutrition(GoalType.LOSE_WEIGHT, "62", 12, "0.50", "1900", "100", "210", "60"),
                        List.of("LOW_CARB", "DAIRY_FREE"),
                        List.of(allergy(1L, AllergySeverity.MEDIUM), allergy(2L, AllergySeverity.MEDIUM)),
                        List.of(3L, 9L, 11L),
                        foodLogs(firstLogDate, new long[]{3, 5, 9, 11, 13}, false, true, false)),
                user(
                        "son.ho.seed@example.com",
                        "Ho Son",
                        LocalDate.of(1972, 7, 30),
                        Gender.MALE,
                        health("169", "74", ActivityLevel.MODERATE),
                        nutrition(GoalType.MAINTAIN, "74", 12, "0.00", "2000", "110", "230", "65"),
                        List.of("NORMAL", "BALANCED"),
                        List.of(allergy(5L, AllergySeverity.LOW), allergy(7L, AllergySeverity.MEDIUM)),
                        List.of(1L, 4L, 12L),
                        foodLogs(firstLogDate, new long[]{1, 4, 7, 12, 15}, false, false, false)));
    }

    private static SeedUser user(
            String email,
            String fullName,
            LocalDate dob,
            Gender gender,
            SeedHealthProfile healthProfile,
            SeedNutritionGoal nutritionGoal,
            List<String> dietTypes,
            List<SeedAllergy> allergies,
            List<Long> favoriteRecipeIds,
            List<SeedFoodLog> foodLogs) {
        return new SeedUser(
                email,
                PASSWORD_HASH,
                fullName,
                dob,
                gender,
                healthProfile,
                nutritionGoal,
                dietTypes,
                allergies,
                favoriteRecipeIds,
                foodLogs);
    }

    private static SeedHealthProfile health(String height, String weight, ActivityLevel activityLevel) {
        return new SeedHealthProfile(new BigDecimal(height), new BigDecimal(weight), activityLevel);
    }

    private static SeedNutritionGoal nutrition(
            GoalType goalType,
            String targetWeight,
            Integer durationWeeks,
            String weeklyRateKg,
            String calories,
            String protein,
            String carbs,
            String fat) {
        return new SeedNutritionGoal(
                goalType,
                new BigDecimal(targetWeight),
                durationWeeks,
                new BigDecimal(weeklyRateKg),
                new BigDecimal(calories),
                new BigDecimal(protein),
                new BigDecimal(carbs),
                new BigDecimal(fat));
    }

    private static SeedAllergy allergy(Long allergenId, AllergySeverity severity) {
        return new SeedAllergy(allergenId, severity);
    }

    private static List<SeedFoodLog> foodLogs(
            LocalDate firstLogDate,
            long[] recipeRotation,
            boolean skipBreakfastOften,
            boolean snackOften,
            boolean highProteinPattern) {
        List<SeedFoodLog> logs = new ArrayList<>();
        for (int day = 0; day < 30; day++) {
            LocalDate logDate = firstLogDate.plusDays(day);
            if (day % 3 == 0 && (!skipBreakfastOften || day % 5 != 0)) {
                logs.add(foodLog(recipeRotation, day, 0, MealType.BREAKFAST, highProteinPattern ? "1.25" : "1.00", logDate));
            }
            if (day % 2 == 0) {
                logs.add(foodLog(recipeRotation, day, 1, MealType.LUNCH, highProteinPattern ? "1.50" : "1.25", logDate));
            } else {
                logs.add(foodLog(recipeRotation, day, 2, MealType.DINNER, highProteinPattern ? "1.50" : "1.00", logDate));
            }
            if ((snackOften && day % 3 == 1) || (!snackOften && day % 5 == 2)) {
                logs.add(foodLog(recipeRotation, day, 3, MealType.SNACK, "0.50", logDate));
            }
        }
        return logs;
    }

    private static SeedFoodLog foodLog(
            long[] recipeRotation,
            int day,
            int mealOffset,
            MealType mealType,
            String quantity,
            LocalDate logDate) {
        Long recipeId = recipeRotation[(day + mealOffset) % recipeRotation.length];
        return new SeedFoodLog(recipeId, new BigDecimal(quantity), mealType, logDate);
    }

    public record SeedUser(
            String email,
            String passwordHash,
            String fullName,
            LocalDate dob,
            Gender gender,
            SeedHealthProfile healthProfile,
            SeedNutritionGoal nutritionGoal,
            List<String> dietTypes,
            List<SeedAllergy> allergies,
            List<Long> favoriteRecipeIds,
            List<SeedFoodLog> foodLogs) {
    }

    public record SeedHealthProfile(
            BigDecimal height,
            BigDecimal weight,
            ActivityLevel activityLevel) {
    }

    public record SeedNutritionGoal(
            GoalType goalType,
            BigDecimal targetWeight,
            Integer durationWeeks,
            BigDecimal weeklyRateKg,
            BigDecimal calories,
            BigDecimal protein,
            BigDecimal carbs,
            BigDecimal fat) {
    }

    public record SeedAllergy(
            Long allergenId,
            AllergySeverity severity) {
    }

    public record SeedFoodLog(
            Long recipeId,
            BigDecimal quantity,
            MealType mealType,
            LocalDate logDate) {
    }
}
