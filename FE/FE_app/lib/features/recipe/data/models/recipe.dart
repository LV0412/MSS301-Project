class Recipe {
  const Recipe({
    required this.recipeId,
    required this.title,
    required this.description,
    required this.preparationTime,
    required this.cookTime,
    required this.difficulty,
    required this.dietTypes,
    required this.ingredients,
    this.categoryName,
    this.nutrition,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final nutrition = json['nutrition'];
    final ingredients = json['ingredients'];
    final dietTypes = json['dietTypes'];

    return Recipe(
      recipeId: (json['recipeId'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
      cookTime: (json['cookTime'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? '',
      categoryName: category is Map ? category['name']?.toString() : null,
      dietTypes: dietTypes is List
          ? dietTypes.map((item) => item.toString()).toList()
          : const [],
      ingredients: ingredients is List
          ? ingredients
                .whereType<Map>()
                .map(
                  (item) => RecipeIngredient.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ),
                )
                .toList()
          : const [],
      nutrition: nutrition is Map
          ? RecipeNutrition.fromJson(
              nutrition.map((key, value) => MapEntry('$key', value)),
            )
          : null,
    );
  }

  final int recipeId;
  final String title;
  final String description;
  final int preparationTime;
  final int cookTime;
  final String difficulty;
  final String? categoryName;
  final List<String> dietTypes;
  final List<RecipeIngredient> ingredients;
  final RecipeNutrition? nutrition;

  int get totalMinutes => preparationTime + cookTime;
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit']?.toString() ?? '',
    );
  }

  final String name;
  final double? quantity;
  final String unit;
}

class RecipeNutrition {
  const RecipeNutrition({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    return RecipeNutrition(
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    );
  }

  final double calories;
  final double protein;
  final double fat;
  final double carbs;
}
