class NutritionGoal {
  const NutritionGoal({
    required this.goalType,
    required this.goalConfigured,
    this.targetWeight,
    this.durationWeeks,
    this.weeklyRateKg,
    this.recommendedCalories,
    this.dailyCaloriesGoal,
    this.protein,
    this.carbs,
    this.fat,
    this.warnings = const [],
  });

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      goalType: json['goalType']?.toString(),
      goalConfigured: json['goalConfigured'] == true,
      targetWeight: _asDouble(json['targetWeight']),
      durationWeeks: (json['durationWeeks'] as num?)?.toInt(),
      weeklyRateKg: _asDouble(json['weeklyRateKg']),
      recommendedCalories: _asDouble(json['recommendedCalories']),
      dailyCaloriesGoal: _asDouble(json['dailyCaloriesGoal']),
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fat: _asDouble(json['fat']),
      warnings: _asStringList(json['warnings']),
    );
  }

  final String? goalType;
  final bool goalConfigured;
  final double? targetWeight;
  final int? durationWeeks;
  final double? weeklyRateKg;
  final double? recommendedCalories;
  final double? dailyCaloriesGoal;
  final double? protein;
  final double? carbs;
  final double? fat;
  final List<String> warnings;

  bool get isConfigured => goalConfigured;
  bool get hasWeightPlan => isConfigured && goalType != 'MAINTAIN';
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList(growable: false);
}
