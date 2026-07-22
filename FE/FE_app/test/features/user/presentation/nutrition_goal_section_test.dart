import 'package:fe_nutritionai/app.dart';
import 'package:fe_nutritionai/features/user/data/models/nutrition_goal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget subject(NutritionGoal goal) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: NutritionGoalSection(nutritionGoal: goal),
        ),
      ),
    );
  }

  testWidgets('shows setup CTA when goal is not configured', (tester) async {
    await tester.pumpWidget(
      subject(const NutritionGoal(goalType: null, goalConfigured: false)),
    );

    expect(find.text('Bạn chưa thiết lập mục tiêu calo'), findsOneWidget);
    expect(find.text('Thiết lập mục tiêu'), findsOneWidget);
    expect(find.textContaining('Gợi ý hệ thống:'), findsNothing);
  });

  testWidgets('shows metrics without a weight plan for maintain goal', (
    tester,
  ) async {
    await tester.pumpWidget(
      subject(
        const NutritionGoal(
          goalType: 'MAINTAIN',
          goalConfigured: true,
          recommendedCalories: 2100,
          dailyCaloriesGoal: 2200,
          protein: 100,
          carbs: 250,
          fat: 65,
        ),
      ),
    );

    expect(find.text('2200 kcal', findRichText: true), findsOneWidget);
    expect(find.text('Gợi ý hệ thống: 2100 kcal/ngày'), findsOneWidget);
    expect(find.textContaining('Mục tiêu: '), findsNothing);
    expect(find.byIcon(Icons.warning_amber_outlined), findsNothing);
  });

  testWidgets('shows weight plan and persistent warnings', (tester) async {
    await tester.pumpWidget(
      subject(
        const NutritionGoal(
          goalType: 'LOSE_WEIGHT',
          goalConfigured: true,
          targetWeight: 55,
          durationWeeks: 30,
          weeklyRateKg: 0.5,
          recommendedCalories: 1900,
          dailyCaloriesGoal: 1950,
          protein: 110,
          carbs: 190,
          fat: 55,
          warnings: ['Target BMI is below 18.5.'],
        ),
      ),
    );

    expect(
      find.text('Mục tiêu: Giảm cân · 55kg · trong 30 tuần · 0.5kg/tuần'),
      findsOneWidget,
    );
    expect(find.text('Target BMI is below 18.5.'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });
}
