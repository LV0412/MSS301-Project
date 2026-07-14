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
    required this.steps,
    required this.servings,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.nutrition,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final nutrition = json['nutrition'];
    final ingredients = json['ingredients'];
    final steps = json['steps'];
    final dietTypes = json['dietTypes'];

    return Recipe(
      recipeId: (json['recipeId'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
      cookTime: (json['cookTime'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? '',
      categoryId: category is Map
          ? (category['categoryId'] as num?)?.toInt()
          : null,
      categoryName: category is Map ? category['name']?.toString() : null,
      imageUrl: json['imageUrl']?.toString(),
      servings: (json['servings'] as num?)?.toInt() ?? 1,
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
      steps: steps is List
          ? steps
                .whereType<Map>()
                .map(
                  (item) => RecipeStep.fromJson(
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
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  final int recipeId;
  final String title;
  final String description;
  final int preparationTime;
  final int cookTime;
  final String difficulty;
  final int? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final int servings;
  final List<String> dietTypes;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final RecipeNutrition? nutrition;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get totalMinutes => preparationTime + cookTime;
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.allergens,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredientId: (json['ingredientId'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit']?.toString() ?? '',
      allergens: json['allergens'] is List
          ? (json['allergens'] as List)
                .whereType<Map>()
                .map(
                  (item) => RecipeAllergen.fromJson(
                    item.map((key, value) => MapEntry('$key', value)),
                  ),
                )
                .toList()
          : const [],
    );
  }

  final int? ingredientId;
  final String name;
  final double? quantity;
  final String unit;
  final List<RecipeAllergen> allergens;
}

class RecipeAllergen {
  const RecipeAllergen({required this.allergenId, required this.name});

  factory RecipeAllergen.fromJson(Map<String, dynamic> json) {
    return RecipeAllergen(
      allergenId: (json['allergenId'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
    );
  }

  final int? allergenId;
  final String name;
}

class RecipeStep {
  const RecipeStep({
    required this.stepId,
    required this.stepOrder,
    required this.instruction,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepId: (json['stepId'] as num?)?.toInt(),
      stepOrder: (json['stepOrder'] as num?)?.toInt() ?? 0,
      instruction: json['instruction']?.toString() ?? '',
    );
  }

  final int? stepId;
  final int stepOrder;
  final String instruction;
}

class RecipeNutrition {
  const RecipeNutrition({
    required this.nutritionId,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    return RecipeNutrition(
      nutritionId: (json['nutritionId'] as num?)?.toInt(),
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
    );
  }

  final int? nutritionId;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double fiber;
  final double sugar;
  final double sodium;
}
