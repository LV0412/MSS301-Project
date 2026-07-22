part of '../../../app.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, color: AppColors.green),
        ),
        const SizedBox(width: 9),
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Nhật ký ăn uống',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodLogScreen()),
          ),
          icon: const Icon(Icons.restaurant_menu, color: AppColors.darkGreen),
        ),
        IconButton(
          tooltip: 'Món yêu thích',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoriteRecipesScreen()),
          ),
          icon: const Icon(Icons.favorite_border, color: AppColors.darkGreen),
        ),
        IconButton(
          tooltip: 'Tìm món theo nguyên liệu',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AiChefIngredientScannerScreen(),
            ),
          ),
          icon: const Icon(
            Icons.document_scanner_outlined,
            color: AppColors.darkGreen,
          ),
        ),
      ],
    );
  }
}

class DailyCaloriesCard extends StatefulWidget {
  const DailyCaloriesCard({super.key});

  @override
  State<DailyCaloriesCard> createState() => _DailyCaloriesCardState();
}

class _DailyCaloriesCardState extends State<DailyCaloriesCard> {
  late Future<_DailyCaloriesData> _dataFuture = _loadData();

  Future<_DailyCaloriesData> _loadData() async {
    final dependencies = AuthDependencies.instance;
    final profile = await dependencies.userRepository.getCurrentUser();
    final nutritionGoal = await dependencies.userRepository.getNutritionGoal();
    final logs = await dependencies.foodLogStore.load(
      date: _foodLogIsoDate(DateTime.now()),
    );
    final consumedCalories = logs.fold<double>(0, (total, entry) {
      final caloriesPerServing = entry.recipe?.nutrition?.calories;
      if (caloriesPerServing == null) return total;
      return total + (caloriesPerServing * entry.quantity);
    });

    return _DailyCaloriesData(
      fullName: profile.fullName,
      consumedCalories: consumedCalories,
      targetCalories: nutritionGoal.isConfigured
          ? nutritionGoal.dailyCaloriesGoal
          : null,
    );
  }

  void _reload() => setState(() => _dataFuture = _loadData());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DailyCaloriesData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }
        if (snapshot.hasError) {
          return ApiMessageBanner(
            message: 'Không thể tải dữ liệu calo hôm nay.',
            isError: true,
            actionLabel: 'Thử lại',
            onAction: _reload,
          );
        }
        return _DailyCaloriesContent(data: snapshot.data!);
      },
    );
  }
}

class _DailyCaloriesContent extends StatelessWidget {
  const _DailyCaloriesContent({required this.data});

  final _DailyCaloriesData data;

  @override
  Widget build(BuildContext context) {
    final target = data.targetCalories;
    final remaining = target == null
        ? null
        : (target - data.consumedCalories).clamp(0, double.infinity).toDouble();
    final progress = target == null || target <= 0
        ? 0.0
        : (data.consumedCalories / target).clamp(0, 1).toDouble();
    final displayName = data.fullName.trim().isEmpty
        ? 'bạn'
        : data.fullName.trim().split(RegExp(r'\s+')).last;
    final statusText = target == null
        ? 'Bạn chưa thiết lập mục tiêu calo trong hồ sơ.'
        : remaining! > 0
        ? 'Hôm nay bạn cần nạp thêm ${_formatCalories(remaining)} kcal\nđể đạt mục tiêu.'
        : 'Bạn đã đạt mục tiêu calo hôm nay.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greetingFor(DateTime.now())}, $displayName',
          style: const TextStyle(
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: const TextStyle(
            fontSize: 17,
            height: 1.35,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 32),
        if (target == null)
          _NutritionGoalSetupCard(
            onPressed: () => _openNutritionGoalSetup(context),
          )
        else
          Container(
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CALO HẰNG NGÀY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 198,
                    height: 198,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 168,
                          height: 168,
                          child: CircularProgressIndicator(
                            value: 0,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            color: AppColors.green,
                            backgroundColor: AppColors.line,
                          ),
                        ),
                        SizedBox(
                          width: 168,
                          height: 168,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            color: AppColors.green,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatCalories(data.consumedCalories),
                              style: const TextStyle(
                                fontSize: 44,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đã nạp / ${_formatCalories(target)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

void _openNutritionGoalSetup(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LifestyleScreen(
        completeDestination: MainShell(),
      ),
    ),
  );
}

class _NutritionGoalSetupCard extends StatelessWidget {
  const _NutritionGoalSetupCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CALO HẰNG NGÀY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          const Icon(
            Icons.track_changes,
            color: AppColors.green,
            size: 34,
          ),
          const SizedBox(height: 14),
          const Text(
            'Bạn chưa thiết lập mục tiêu calo',
            style: TextStyle(
              fontSize: 20,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hoàn thành 4 bước hồ sơ để ứng dụng tính calo và macro hằng ngày.',
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward, size: 17),
            label: const Text('Thiết lập mục tiêu'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCaloriesData {
  const _DailyCaloriesData({
    required this.fullName,
    required this.consumedCalories,
    required this.targetCalories,
  });

  final String fullName;
  final double consumedCalories;
  final double? targetCalories;
}

String _greetingFor(DateTime value) {
  if (value.hour < 12) return 'Chào buổi sáng';
  if (value.hour < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

String _formatCalories(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

class HomeAiInsightCard extends StatelessWidget {
  const HomeAiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'PHÂN TÍCH AI',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: .9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Tuần này bạn đã đạt 82% mục tiêu protein. Hãy cân nhắc thêm một phần ức gà hoặc đậu phụ cho bữa tối để hoàn thành mục tiêu.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class MacroSummaryCard extends StatefulWidget {
  const MacroSummaryCard({super.key});

  @override
  State<MacroSummaryCard> createState() => _MacroSummaryCardState();
}

class _NutritionTotals {
  const _NutritionTotals({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  factory _NutritionTotals.fromLogs(List<FoodLogEntry> logs) {
    var calories = 0.0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    var fiber = 0.0;
    var sugar = 0.0;
    var sodium = 0.0;
    for (final entry in logs) {
      final nutrition = entry.recipe?.nutrition;
      if (nutrition == null) continue;
      calories += nutrition.calories * entry.quantity;
      protein += nutrition.protein * entry.quantity;
      carbs += nutrition.carbs * entry.quantity;
      fat += nutrition.fat * entry.quantity;
      fiber += nutrition.fiber * entry.quantity;
      sugar += nutrition.sugar * entry.quantity;
      sodium += nutrition.sodium * entry.quantity;
    }
    return _NutritionTotals(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
    );
  }

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  _NutritionTotals operator +(_NutritionTotals other) => _NutritionTotals(
    calories: calories + other.calories,
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    fat: fat + other.fat,
    fiber: fiber + other.fiber,
    sugar: sugar + other.sugar,
    sodium: sodium + other.sodium,
  );
}

class _WeeklyNutritionData {
  const _WeeklyNutritionData({
    required this.days,
    required this.dailyTotals,
    required this.total,
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
  });
  final List<DateTime> days;
  final List<_NutritionTotals> dailyTotals;
  final _NutritionTotals total;
  final double? caloriesTarget;
  final double? proteinTarget;
  final double? carbsTarget;
  final double? fatTarget;

  double get calorieProgress =>
      _weeklyMacroProgress(total.calories, caloriesTarget);
}

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';

String _weeklyMacroValue(double consumed, double? dailyTarget) {
  final target = dailyTarget == null ? null : dailyTarget * 7;
  final current = _formatNumber(consumed);
  return target == null
      ? '${current}g / Chưa đặt'
      : '${current}g / ${_formatNumber(target)}g';
}

double _weeklyMacroProgress(double consumed, double? dailyTarget) {
  if (dailyTarget == null || dailyTarget <= 0) return 0;
  return (consumed / (dailyTarget * 7)).clamp(0, 1).toDouble();
}

class _MacroSummaryData {
  const _MacroSummaryData({
    required this.consumed,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
  });
  final _NutritionTotals consumed;
  final double? proteinTarget;
  final double? carbsTarget;
  final double? fatTarget;

  bool get hasTargets =>
      proteinTarget != null || carbsTarget != null || fatTarget != null;
}

String _macroValue(double consumed, double? target) {
  final current = _formatNumber(consumed);
  return target == null
      ? '${current}g / Chưa đặt'
      : '${current}g / ${_formatNumber(target)}g';
}

double _macroProgress(double consumed, double? target) {
  if (target == null || target <= 0) return 0;
  return (consumed / target).clamp(0, 1).toDouble();
}

String _nutrientValue(double consumed, String unit) {
  return '${_formatNumber(consumed)} $unit';
}

class _MacroSummaryCardState extends State<MacroSummaryCard> {
  late Future<_MacroSummaryData> _future = _load();

  Future<_MacroSummaryData> _load() async {
    final dependencies = AuthDependencies.instance;
    final results = await Future.wait([
      dependencies.userRepository.getNutritionGoal(),
      dependencies.foodLogStore.load(date: _foodLogIsoDate(DateTime.now())),
    ]);
    final goal = results[0] as NutritionGoal?;
    final hasGoal = goal?.isConfigured == true;
    return _MacroSummaryData(
      consumed: _NutritionTotals.fromLogs(results[1] as List<FoodLogEntry>),
      proteinTarget: hasGoal ? goal?.protein : null,
      carbsTarget: hasGoal ? goal?.carbs : null,
      fatTarget: hasGoal ? goal?.fat : null,
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MacroSummaryData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }
        if (snapshot.hasError) {
          return ApiMessageBanner(
            message: 'Không thể tải dữ liệu macro hôm nay.',
            isError: true,
            actionLabel: 'Thử lại',
            onAction: _retry,
          );
        }
        return _MacroSummaryContent(data: snapshot.requireData);
      },
    );
  }
}

class _MacroSummaryContent extends StatelessWidget {
  const _MacroSummaryContent({required this.data});
  final _MacroSummaryData data;

  @override
  Widget build(BuildContext context) {
    if (!data.hasTargets) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          MacroProgressRow(
            label: 'ĐẠM (PROTEIN)',
            value: _macroValue(data.consumed.protein, data.proteinTarget),
            progress: _macroProgress(data.consumed.protein, data.proteinTarget),
            color: AppColors.green,
          ),
          const SizedBox(height: 14),
          MacroProgressRow(
            label: 'TINH BỘT (CARB)',
            value: _macroValue(data.consumed.carbs, data.carbsTarget),
            progress: _macroProgress(data.consumed.carbs, data.carbsTarget),
            color: const Color(0xFFB8A086),
          ),
          const SizedBox(height: 14),
          MacroProgressRow(
            label: 'CHẤT BÉO (FAT)',
            value: _macroValue(data.consumed.fat, data.fatTarget),
            progress: _macroProgress(data.consumed.fat, data.fatTarget),
            color: const Color(0xFF5F6057),
          ),
          const SizedBox(height: 14),
          MacroProgressRow(
            label: 'CHẤT XƠ',
            value: _nutrientValue(data.consumed.fiber, 'g'),
            color: const Color(0xFF78946A),
          ),
          const SizedBox(height: 14),
          MacroProgressRow(
            label: 'ĐƯỜNG',
            value: _nutrientValue(data.consumed.sugar, 'g'),
            color: const Color(0xFFC28B5C),
          ),
          const SizedBox(height: 14),
          MacroProgressRow(
            label: 'NATRI',
            value: _nutrientValue(data.consumed.sodium, 'mg'),
            color: const Color(0xFF7D8996),
          ),
        ],
      ),
    );
  }
}

class MacroProgressRow extends StatelessWidget {
  const MacroProgressRow({
    super.key,
    required this.label,
    required this.value,
    this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double? progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: AppColors.line,
            ),
          ),
        ],
      ],
    );
  }
}

class TodayMenuHeader extends StatelessWidget {
  const TodayMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Công thức mới nhất',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

enum MealPalette { breakfast, lunch, dinner }

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.recipeId,
    required this.label,
    required this.title,
    required this.time,
    required this.calories,
    required this.palette,
    this.imageUrl,
  });

  factory MealCard.fromRecipe({
    required Recipe recipe,
    required String label,
    required MealPalette palette,
  }) {
    final nutrition = recipe.nutrition;
    return MealCard(
      recipeId: recipe.recipeId,
      label: label,
      title: recipe.title,
      time: '${recipe.totalMinutes} PH',
      calories: nutrition == null
          ? '- KCAL'
          : '${_formatNumber(nutrition.calories)} KCAL',
      palette: palette,
      imageUrl: recipe.imageUrl,
    );
  }

  final int recipeId;
  final String label;
  final String title;
  final String time;
  final String calories;
  final MealPalette palette;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRecipeDetails(context, recipeId, title),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: AppColors.darkGreen.withValues(alpha: .05),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 156,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeApiImage(imageUrl: imageUrl, palette: palette),
                  Positioned(
                    left: 18,
                    top: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 15,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.local_fire_department_outlined,
                        size: 15,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiTodayMealList extends StatefulWidget {
  const ApiTodayMealList({super.key});

  @override
  State<ApiTodayMealList> createState() => _ApiTodayMealListState();
}

class _ApiTodayMealListState extends State<ApiTodayMealList> {
  late Future<List<Recipe>> _future = _load();

  Future<List<Recipe>> _load() =>
      AuthDependencies.instance.recipeRepository.getRecipes(size: 3);

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }
        if (snapshot.hasError) {
          return ApiMessageBanner(
            message: 'Không thể tải danh sách công thức mới.',
            isError: true,
            actionLabel: 'Thử lại',
            onAction: _retry,
          );
        }
        final recipes = snapshot.data ?? const [];
        if (recipes.isEmpty) {
          return const ApiMessageBanner(
            message: 'Recipe service chưa có công thức mới.',
          );
        }

        return Column(
          children: [
            for (var index = 0; index < recipes.length; index++) ...[
              MealCard.fromRecipe(
                recipe: recipes[index],
                label: recipes[index].categoryName ?? 'CÔNG THỨC',
                palette: _paletteForIndex(index),
              ),
              if (index != recipes.length - 1) const SizedBox(height: 18),
            ],
          ],
        );
      },
    );
  }
}

class RecipeApiImage extends StatelessWidget {
  const RecipeApiImage({
    super.key,
    required this.imageUrl,
    required this.palette,
  });

  final String? imageUrl;
  final MealPalette palette;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return MealArt(palette: palette);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => MealArt(palette: palette),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Stack(
          fit: StackFit.expand,
          children: [
            MealArt(palette: palette),
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.green,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatRecipeDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

class MealArt extends StatelessWidget {
  const MealArt({super.key, required this.palette});

  final MealPalette palette;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (palette) {
      MealPalette.breakfast => const [
        Color(0xFFEEF5DA),
        Color(0xFF8FB65D),
        Color(0xFFFFF9E4),
      ],
      MealPalette.lunch => const [
        Color(0xFFF4D5AD),
        Color(0xFFE7B870),
        Color(0xFFF7E8C6),
      ],
      MealPalette.dinner => const [
        Color(0xFF1D2019),
        Color(0xFF6A4E35),
        Color(0xFFE7B45C),
      ],
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: CustomPaint(painter: _MealArtPainter(palette)),
    );
  }
}

class EmptyMealPlanCard extends StatelessWidget {
  const EmptyMealPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: AppColors.field,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 44,
                  color: Color(0xFFB5BDB0),
                ),
                SizedBox(height: 18),
                Text(
                  'Thêm bữa nhẹ để bổ sung protein',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chưa có kế hoạch',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    this.selected = HomeTab.home,
    this.onSelected,
  });

  final HomeTab selected;
  final ValueChanged<HomeTab>? onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Trang chủ', HomeTab.home),
      (Icons.search, 'Khám phá', HomeTab.explore),
      (Icons.person_outline, 'Hồ sơ', HomeTab.profile),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (item.$3 == selected) return;
                  final callback = onSelected;
                  callback == null
                      ? _openTab(context, item.$3)
                      : callback(item.$3);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: selected == item.$3 ? 62 : 42,
                      height: 34,
                      decoration: BoxDecoration(
                        color: selected == item.$3
                            ? const Color(0xFFB7C8B6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Icon(item.$1, size: 20, color: AppColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$2.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.05,
                        fontWeight: selected == item.$3
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openTab(BuildContext context, HomeTab tab) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainShell(initialTab: tab)),
    );
  }
}

enum HomeTab { home, explore, profile }

class _MealArtPainter extends CustomPainter {
  _MealArtPainter(this.palette);

  final MealPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    switch (palette) {
      case MealPalette.breakfast:
        _paintBreakfast(canvas, size);
      case MealPalette.lunch:
        _paintLunch(canvas, size);
      case MealPalette.dinner:
        _paintDinner(canvas, size);
    }
  }

  void _paintBreakfast(Canvas canvas, Size size) {
    final plate = Paint()..color = Colors.white.withValues(alpha: .92);
    canvas.drawCircle(Offset(size.width * .62, size.height * .52), 88, plate);
    final avocado = Paint()..color = const Color(0xFF73A64D);
    for (var i = 0; i < 8; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (.24 + i * .045), size.height * .54),
          width: 42,
          height: 116,
        ),
        avocado
          ..color = Color.lerp(
            const Color(0xFF4F8D38),
            const Color(0xFFA7C96C),
            i / 8,
          )!,
      );
    }
    final eggWhite = Paint()..color = Colors.white;
    final yolk = Paint()..color = const Color(0xFFF2D276);
    canvas.drawCircle(
      Offset(size.width * .58, size.height * .45),
      38,
      eggWhite,
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .48),
      37,
      eggWhite,
    );
    canvas.drawCircle(Offset(size.width * .58, size.height * .45), 14, yolk);
    canvas.drawCircle(Offset(size.width * .72, size.height * .48), 13, yolk);
    final salmon = Paint()..color = const Color(0xFFF06D45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .47, size.height * .72, 128, 42),
        const Radius.circular(24),
      ),
      salmon,
    );
  }

  void _paintLunch(Canvas canvas, Size size) {
    final bowl = Paint()..color = const Color(0xFFF5E8CC);
    canvas.drawCircle(Offset(size.width * .52, size.height * .55), 108, bowl);
    final colors = [
      const Color(0xFFE2AA2D),
      const Color(0xFF7A4F33),
      const Color(0xFF7CA163),
      const Color(0xFFDD4935),
      const Color(0xFFF3D7A4),
    ];
    for (var i = 0; i < 45; i++) {
      final x = size.width * (.22 + (i % 9) * .07);
      final y = size.height * (.23 + (i ~/ 9) * .12);
      canvas.drawCircle(
        Offset(x, y),
        10 + (i % 3) * 2,
        Paint()..color = colors[i % colors.length],
      );
    }
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .48),
      34,
      Paint()..color = const Color(0xFFEAD7A8),
    );
  }

  void _paintDinner(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .58, size.width, size.height * .42),
      Paint()..color = Colors.black.withValues(alpha: .25),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .25, size.height * .55, 166, 44),
        const Radius.circular(28),
      ),
      Paint()..color = const Color(0xFFE87945),
    );
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * (.28 + i * .06), size.height * .58),
        Offset(size.width * (.34 + i * .06), size.height * .78),
        Paint()
          ..color = const Color(0xFFFFC081).withValues(alpha: .8)
          ..strokeWidth = 3,
      );
    }
    final asparagus = Paint()..color = const Color(0xFF6EA34E);
    for (var i = 0; i < 8; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * .55,
            size.height * (.58 + i * .025),
            118,
            5,
          ),
          const Radius.circular(4),
        ),
        asparagus,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MealArtPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}
