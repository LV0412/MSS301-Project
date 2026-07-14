part of '../../../app.dart';

class MealPlannerHeader extends StatelessWidget {
  const MealPlannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        const CircleAvatar(
          radius: 15,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, size: 17, color: AppColors.green),
        ),
      ],
    );
  }
}

class PlannerActionButtons extends StatelessWidget {
  const PlannerActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: []);
  }
}

class CalorieTargetPanel extends StatelessWidget {
  const CalorieTargetPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'DAILY CALORIE TARGET',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Icon(Icons.insert_chart_outlined, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 26),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2,150',
                style: TextStyle(
                  fontSize: 54,
                  height: .92,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  'kcal',
                  style: TextStyle(fontSize: 17, color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: .85,
              minHeight: 7,
              color: AppColors.green,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '1,820 / 2,150 CONSUMED',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class MacroBalancePanel extends StatelessWidget {
  const MacroBalancePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MACRONUTRIENT BALANCE',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: .8,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MacroRing(value: '30%', label: 'PROTEIN', color: AppColors.green),
              MacroRing(value: '45%', label: 'CARBS', color: Color(0xFFB49473)),
              MacroRing(value: '25%', label: 'FAT', color: AppColors.line),
            ],
          ),
        ],
      ),
    );
  }
}

class MacroRing extends StatelessWidget {
  const MacroRing({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: .7,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class PlannerInsightPanel extends StatelessWidget {
  const PlannerInsightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: .55),
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
              Icon(Icons.auto_awesome, size: 21, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'AI INSIGHT',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            '"Increasing your protein intake by 15g at breakfast will help stabilize your energy levels for your scheduled Tuesday morning workout."',
            style: TextStyle(fontSize: 17, height: 1.48, color: AppColors.ink),
          ),
          SizedBox(height: 10),
          Text(
            'VIEW RECOMMENDATIONS',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class PlannerDaySelector extends StatelessWidget {
  const PlannerDaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          Padding(
            padding: EdgeInsets.only(right: 62, top: 5),
            child: Text(
              'Monday, Oct 23',
              style: TextStyle(fontSize: 18, color: AppColors.ink),
            ),
          ),
          DayPill(label: 'TODAY'),
          SizedBox(width: 36),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Tue',
              style: TextStyle(fontSize: 16, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class DayPill extends StatelessWidget {
  const DayPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF9AAC95),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: .8,
          fontWeight: FontWeight.w900,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class PlannerMealCard extends StatelessWidget {
  const PlannerMealCard({
    super.key,
    required this.recipeId,
    required this.meal,
    required this.title,
    required this.meta,
    required this.palette,
    this.imageUrl,
    this.warning = false,
  });

  factory PlannerMealCard.fromRecipe({
    required Recipe recipe,
    required String meal,
    required MealPalette palette,
  }) {
    final nutrition = recipe.nutrition;
    final meta = nutrition == null
        ? '${recipe.totalMinutes} phút'
        : '${_formatNumber(nutrition.calories)} kcal • ${_formatNumber(nutrition.protein)}g protein';

    return PlannerMealCard(
      recipeId: recipe.recipeId,
      meal: meal,
      title: recipe.title,
      meta: meta,
      palette: palette,
      imageUrl: recipe.imageUrl,
    );
  }

  final int recipeId;
  final String meal;
  final String title;
  final String meta;
  final MealPalette palette;
  final String? imageUrl;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRecipeDetails(context, recipeId, title),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: warning
              ? Border.all(color: const Color(0xFFEBA9A9), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meal,
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (warning)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD71920),
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: RecipeApiImage(imageUrl: imageUrl, palette: palette),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        meta,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: warning
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: warning
                              ? const Color(0xFFD71920)
                              : AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (warning) ...[
              const SizedBox(height: 22),
              const SwapAlternativeButton(),
            ],
          ],
        ),
      ),
    );
  }
}

class ApiPlannerMealList extends StatefulWidget {
  const ApiPlannerMealList({super.key});

  @override
  State<ApiPlannerMealList> createState() => _ApiPlannerMealListState();
}

class _ApiPlannerMealListState extends State<ApiPlannerMealList> {
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
            message: 'Không thể tải danh sách công thức.',
            isError: true,
            actionLabel: 'Thử lại',
            onAction: _retry,
          );
        }

        final recipes = snapshot.data ?? const [];
        if (recipes.isEmpty) {
          return const ApiMessageBanner(
            message: 'Recipe service chưa có dữ liệu thực đơn.',
          );
        }

        return Column(
          children: [
            for (var index = 0; index < recipes.length; index++) ...[
              PlannerMealCard.fromRecipe(
                recipe: recipes[index],
                meal: recipes[index].categoryName ?? 'CÔNG THỨC',
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

class SwapAlternativeButton extends StatelessWidget {
  const SwapAlternativeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: 12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: const Text(
          'SWAP FOR SAFE ALTERNATIVE',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: .9,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class AddSnackButton extends StatelessWidget {
  const AddSnackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: 16),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: AppColors.ink),
            SizedBox(width: 8),
            Text(
              'ADD SNACK',
              style: TextStyle(fontSize: 17, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8BFB1)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 8);
        canvas.drawPath(extract, paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}
