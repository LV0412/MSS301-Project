import 'package:fe_nutritionai/features/user/data/models/nutrition_goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionGoal.fromJson', () {
    test('parses an unconfigured goal', () {
      final goal = NutritionGoal.fromJson({
        'goalConfigured': false,
        'goalType': null,
        'targetWeight': null,
        'durationWeeks': null,
        'weeklyRateKg': null,
        'recommendedCalories': null,
        'dailyCaloriesGoal': null,
        'protein': null,
        'carbs': null,
        'fat': null,
        'warnings': <String>[],
      });

      expect(goal.isConfigured, isFalse);
      expect(goal.goalType, isNull);
      expect(goal.dailyCaloriesGoal, isNull);
      expect(goal.warnings, isEmpty);
    });

    test('parses a configured maintain goal', () {
      final goal = NutritionGoal.fromJson({
        'goalConfigured': true,
        'goalType': 'MAINTAIN',
        'recommendedCalories': 2100.5,
        'dailyCaloriesGoal': 2200,
        'protein': 100,
        'carbs': 250,
        'fat': 65,
        'warnings': <String>[],
      });

      expect(goal.isConfigured, isTrue);
      expect(goal.goalType, 'MAINTAIN');
      expect(goal.dailyCaloriesGoal, 2200);
      expect(goal.hasWeightPlan, isFalse);
    });

    test('parses a configured weight-change goal and warnings', () {
      final goal = NutritionGoal.fromJson({
        'goalConfigured': true,
        'goalType': 'LOSE_WEIGHT',
        'targetWeight': '52.5',
        'durationWeeks': 15,
        'weeklyRateKg': '0.50',
        'recommendedCalories': '1750.25',
        'dailyCaloriesGoal': 1800,
        'protein': 110,
        'carbs': 190,
        'fat': 55,
        'warnings': <String>['Target BMI is below 18.5.'],
      });

      expect(goal.hasWeightPlan, isTrue);
      expect(goal.targetWeight, 52.5);
      expect(goal.durationWeeks, 15);
      expect(goal.weeklyRateKg, 0.5);
      expect(goal.recommendedCalories, 1750.25);
      expect(goal.warnings, hasLength(1));
    });
  });

  test('NutritionGoalPreview maps calculated calories and macro fields', () {
    final preview = NutritionGoalPreview.fromJson({
      'goalType': 'LOSE_WEIGHT',
      'targetWeight': 75,
      'durationWeeks': 10,
      'weeklyRateKg': 0.5,
      'bmr': 1750.25,
      'recommendedCalories': 2200,
      'dailyCaloriesGoal': 2300,
      'protein': 115,
      'carbs': 287.5,
      'fat': 76.67,
      'warnings': ['warning'],
    });

    expect(preview.goalType, 'LOSE_WEIGHT');
    expect(preview.weeklyRateKg, 0.5);
    expect(preview.bmr, 1750.25);
    expect(preview.dailyCaloriesGoal, 2300);
    expect(preview.protein, 115);
    expect(preview.warnings, ['warning']);
  });
}
