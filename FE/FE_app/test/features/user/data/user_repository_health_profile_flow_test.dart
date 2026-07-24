import 'package:fe_nutritionai/features/user/data/models/nutrition_goal.dart';
import 'package:fe_nutritionai/features/user/data/user_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingUserRepository extends UserRepository {
  int healthProfileSaveCalls = 0;
  int nutritionGoalSaveCalls = 0;
  double? savedTargetWeight;

  @override
  Future<Map<String, dynamic>> saveHealthProfile({
    required double height,
    required double weight,
    required String activityLevel,
  }) async {
    healthProfileSaveCalls++;
    return {'height': height, 'weight': weight, 'activityLevel': activityLevel};
  }

  @override
  Future<NutritionGoal> saveNutritionGoal({
    required String goalType,
    double? targetWeight,
    int? durationWeeks,
    double? dailyCaloriesGoal,
  }) async {
    nutritionGoalSaveCalls++;
    savedTargetWeight = targetWeight;
    return NutritionGoal(
      goalType: goalType,
      goalConfigured: true,
      targetWeight: targetWeight,
      dailyCaloriesGoal: dailyCaloriesGoal,
    );
  }
}

void main() {
  setUpAll(() {
    dotenv.testLoad(
      fileInput: 'AUTH_API_BASE_URL=http://localhost:8080/api/v1',
    );
  });

  test('edit profile saves health without writing nutrition goal', () async {
    final repository = _RecordingUserRepository();

    await repository.saveHealthProfileFlow(
      isOnboarding: false,
      height: 170,
      weight: 68,
      activityLevel: 'MODERATE',
      dailyCaloriesGoal: 2000,
    );

    expect(repository.healthProfileSaveCalls, 1);
    expect(repository.nutritionGoalSaveCalls, 0);
  });

  test('onboarding creates maintain goal with current weight', () async {
    final repository = _RecordingUserRepository();

    await repository.saveHealthProfileFlow(
      isOnboarding: true,
      height: 170,
      weight: 68,
      activityLevel: 'MODERATE',
      dailyCaloriesGoal: 2000,
    );

    expect(repository.healthProfileSaveCalls, 1);
    expect(repository.nutritionGoalSaveCalls, 1);
    expect(repository.savedTargetWeight, 68);
  });
}
