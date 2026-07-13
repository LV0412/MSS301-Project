import '../../auth/data/auth_repository.dart';
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
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required RecipeRepository recipeRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _recipeRepository = recipeRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final RecipeRepository _recipeRepository;
  int? _userId;

  Future<int> _resolveUserId() async {
    final cached = _userId;
    if (cached != null) return cached;
    final account = await _authRepository.me();
    _userId = account.userId;
    return account.userId;
  }

  Future<List<FoodLogEntry>> load({
    required String date,
    String? mealType,
  }) async {
    final userId = await _resolveUserId();
    final logs = await _userRepository.getFoodLogs(
      userId: userId,
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
      userId: await _resolveUserId(),
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
      userId: await _resolveUserId(),
      logId: logId,
      recipeId: recipeId,
      quantity: quantity,
      mealType: mealType,
      logDate: logDate,
    );
  }

  Future<void> delete(int logId) async {
    await _userRepository.deleteFoodLog(
      userId: await _resolveUserId(),
      logId: logId,
    );
  }

  void clear() => _userId = null;
}
