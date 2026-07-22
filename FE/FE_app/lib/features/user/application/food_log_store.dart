import '../../recipe/data/models/recipe.dart';
import '../../recipe/data/recipe_repository.dart';
import '../data/user_repository.dart';

class FoodLogEntry {
  const FoodLogEntry({
    required this.logId,
    required this.recipeId,
    required this.quantity,
    required this.mealType,
    required this.logDate,
    this.recipe,
  });

  factory FoodLogEntry.fromJson(Map<String, dynamic> json, {Recipe? recipe}) {
    return FoodLogEntry(
      logId: (json['logId'] as num).toInt(),
      recipeId: (json['recipeId'] as num).toInt(),
      quantity: (json['quantity'] as num).toDouble(),
      mealType: json['mealType']?.toString() ?? 'SNACK',
      logDate: json['logDate']?.toString() ?? '',
      recipe: recipe,
    );
  }

  final int logId;
  final int recipeId;
  final double quantity;
  final String mealType;
  final String logDate;
  final Recipe? recipe;
}

class FoodLogStore {
  FoodLogStore({
    required UserRepository userRepository,
    required RecipeRepository recipeRepository,
  }) : _userRepository = userRepository,
       _recipeRepository = recipeRepository;

  final UserRepository _userRepository;
  final RecipeRepository _recipeRepository;

  Future<List<FoodLogEntry>> load({
    required String date,
    String? mealType,
  }) async {
    final logs = await _userRepository.getFoodLogs(
      date: date,
      mealType: mealType,
    );
    final recipes = <int, Recipe>{};
    for (final recipeId
        in logs.map((item) => (item['recipeId'] as num).toInt()).toSet()) {
      try {
        recipes[recipeId] = await _recipeRepository.getRecipe(recipeId);
      } catch (_) {
        // A food log remains useful even if its recipe was removed.
      }
    }
    return logs
        .map(
          (item) => FoodLogEntry.fromJson(
            item,
            recipe: recipes[(item['recipeId'] as num).toInt()],
          ),
        )
        .toList();
  }

  Future<void> create({
    required int recipeId,
    required double quantity,
    required String mealType,
    required String logDate,
  }) async {
    await _userRepository.createFoodLog(
      recipeId: recipeId,
      quantity: quantity,
      mealType: mealType,
      logDate: logDate,
    );
  }

  Future<void> update({
    required int logId,
    required int recipeId,
    required double quantity,
    required String mealType,
    required String logDate,
  }) async {
    await _userRepository.updateFoodLog(
      logId: logId,
      recipeId: recipeId,
      quantity: quantity,
      mealType: mealType,
      logDate: logDate,
    );
  }

  Future<void> delete(int logId) async {
    await _userRepository.deleteFoodLog(logId: logId);
  }

  void clear() {}
}
