import 'package:dio/dio.dart';
import 'package:fe_nutritionai/app.dart';
import 'package:fe_nutritionai/core/network/api_exception.dart';
import 'package:fe_nutritionai/features/user/data/models/nutrition_goal.dart';
import 'package:fe_nutritionai/features/user/data/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserRepository extends UserRepository {
  _FakeUserRepository();

  int previewCalls = 0;
  int saveCalls = 0;
  bool failPreview = false;
  String? savedGoalType;
  double? savedTargetWeight;
  int? savedDurationWeeks;

  @override
  Future<Map<String, dynamic>?> getHealthProfile() async => {
    'height': 170,
    'weight': 80,
    'activityLevel': 'MODERATE',
  };

  @override
  Future<NutritionGoalPreview> previewNutritionGoal({
    required String goalType,
    double? targetWeight,
    int? durationWeeks,
    double? dailyCaloriesGoal,
    CancelToken? cancelToken,
  }) async {
    previewCalls++;
    if (failPreview) {
      throw const ApiException(
        message: 'Target weight and duration weeks are invalid.',
        code: 'INVALID_NUTRITION_GOAL',
        statusCode: 400,
      );
    }
    return NutritionGoalPreview(
      goalType: goalType,
      targetWeight: targetWeight,
      durationWeeks: durationWeeks,
      weeklyRateKg: goalType == 'MAINTAIN' ? null : 0.5,
      bmr: 1750,
      recommendedCalories: 2200,
      dailyCaloriesGoal: dailyCaloriesGoal ?? 2200,
      protein: 110,
      carbs: 275,
      fat: 73.33,
    );
  }

  @override
  Future<NutritionGoal> saveNutritionGoal({
    required String goalType,
    double? targetWeight,
    int? durationWeeks,
    double? dailyCaloriesGoal,
  }) async {
    saveCalls++;
    savedGoalType = goalType;
    savedTargetWeight = targetWeight;
    savedDurationWeeks = durationWeeks;
    return NutritionGoal(
      goalType: goalType,
      goalConfigured: true,
      targetWeight: targetWeight,
      durationWeeks: durationWeeks,
      weeklyRateKg: goalType == 'MAINTAIN' ? null : 0.5,
      recommendedCalories: 2200,
      dailyCaloriesGoal: dailyCaloriesGoal ?? 2200,
      protein: 110,
      carbs: 275,
      fat: 73.33,
    );
  }
}

void main() {
  setUpAll(() {
    dotenv.testLoad(
      fileInput: 'AUTH_API_BASE_URL=http://localhost:8080/api/v1',
    );
  });

  const initialGoal = NutritionGoal(
    goalType: 'MAINTAIN',
    goalConfigured: true,
    recommendedCalories: 2200,
    dailyCaloriesGoal: 2200,
    protein: 110,
    carbs: 275,
    fat: 73.33,
  );

  testWidgets(
    'previews valid weight plan after debounce and saves with PUT data',
    (tester) async {
      final repository = _FakeUserRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: NutritionGoalPlanScreen(
            initialGoal: initialGoal,
            repository: repository,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(repository.previewCalls, 1);
      expect(find.text('Calories gợi ý'), findsOneWidget);

      await tester.tap(find.text('Giảm'));
      await tester.pump();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '75');
      await tester.enterText(fields.at(1), '10');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(repository.previewCalls, 2);
      expect(find.text('0.5 kg/tuần'), findsOneWidget);

      final saveButton = find.text('Lưu mục tiêu');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();
      await tester.pump();

      expect(repository.saveCalls, 1);
      expect(repository.savedGoalType, 'LOSE_WEIGHT');
      expect(repository.savedTargetWeight, 75);
      expect(repository.savedDurationWeeks, 10);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pump();
      expect(find.text('Đã lưu kế hoạch dinh dưỡng.'), findsOneWidget);
    },
  );

  testWidgets('shows inline error and does not preview unsafe weekly rate', (
    tester,
  ) async {
    final repository = _FakeUserRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: NutritionGoalPlanScreen(
          initialGoal: initialGoal,
          repository: repository,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Giảm'));
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '79');
    await tester.enterText(fields.at(1), '20');
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('Điều chỉnh thời gian để tốc độ đạt 0,25-1 kg/tuần.'),
      findsOneWidget,
    );
    expect(repository.previewCalls, 1);
  });

  testWidgets('does not save when the latest preview fails', (tester) async {
    final repository = _FakeUserRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: NutritionGoalPlanScreen(
          initialGoal: initialGoal,
          repository: repository,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(repository.previewCalls, 1);

    repository.failPreview = true;
    final saveButton = find.text('Lưu mục tiêu');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump();

    expect(repository.previewCalls, 2);
    expect(repository.saveCalls, 0);
  });
}
