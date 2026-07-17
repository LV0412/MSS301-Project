part of '../../../app.dart';

class AiChefIngredientScannerScreen extends StatefulWidget {
  const AiChefIngredientScannerScreen({super.key});

  @override
  State<AiChefIngredientScannerScreen> createState() =>
      _AiChefIngredientScannerScreenState();
}

class _AiChefIngredientScannerScreenState
    extends State<AiChefIngredientScannerScreen> {
  final _ingredientController = TextEditingController();
  Timer? _debounce;
  late Future<List<Recipe>> _recipesFuture = _search();

  Future<List<Recipe>> _search() {
    return AuthDependencies.instance.recipeRepository.getRecipes(
      size: 6,
      ingredient: _ingredientController.text,
    );
  }

  void _onIngredientChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _refresh);
    setState(() {});
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _recipesFuture = _search());
  }

  void _clear() {
    _debounce?.cancel();
    _ingredientController.clear();
    _refresh();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
              children: [
                const ScannerHeader(),
                const SizedBox(height: 22),
                const Text(
                  "What's in your kitchen\ntoday?",
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập một nguyên liệu để tìm công thức phù hợp.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 18),
                IngredientInputCard(
                  controller: _ingredientController,
                  onChanged: _onIngredientChanged,
                  onSubmitted: (_) => _refresh(),
                  onClear: _clear,
                ),
                const SizedBox(height: 16),
                const ScannerRecommendedHeader(),
                const SizedBox(height: 10),
                ApiScannerRecipeList(future: _recipesFuture, onRetry: _refresh),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerHeader extends StatelessWidget {
  const ScannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Quay lại',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 20),
        ),
        const Expanded(
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class IngredientInputCard extends StatelessWidget {
  const IngredientInputCard({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: chicken, salmon, spinach...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Xóa nguyên liệu',
                    onPressed: onClear,
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Kết quả được lọc qua tham số ingredient của Recipe Service.',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientTag extends StatelessWidget {
  const IngredientTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class ScannerProfileCard extends StatelessWidget {
  const ScannerProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Profile',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: ScannerProfileInfo(
                  label: 'CURRENT GOAL',
                  value: 'Weight Loss & Lean\nMuscle',
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: .70,
                        strokeWidth: 4,
                        color: AppColors.green,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Text(
                      '70%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: ScannerMiniPill(
                  label: 'ALLERGIES & PREFERENCES',
                  value: 'Gluten-Free   No Shellfish',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'DAILY PROTEIN',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '84g / 120g',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerProfileInfo extends StatelessWidget {
  const ScannerProfileInfo({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScannerMiniPill extends StatelessWidget {
  const ScannerMiniPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 10, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class AskChefCard extends StatelessWidget {
  const AskChefCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 17, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Ask Chef AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Tell me an issue like voice assistant without cooking problem?',
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: Colors.white.withValues(alpha: .78),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Message...',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
                Icon(Icons.send, size: 15, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerRecommendedHeader extends StatelessWidget {
  const ScannerRecommendedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Công thức theo\nnguyên liệu',
            style: TextStyle(
              fontSize: 18,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerRecipeCard extends StatelessWidget {
  const ScannerRecipeCard({
    super.key,
    required this.recipeId,
    required this.title,
    required this.meta,
    required this.tags,
    required this.palette,
    this.imageUrl,
  });

  factory ScannerRecipeCard.fromRecipe({
    required Recipe recipe,
    required MealPalette palette,
  }) {
    final nutrition = recipe.nutrition;
    final meta = nutrition == null
        ? '${recipe.totalMinutes} phút'
        : '${recipe.totalMinutes} phút • ${_formatNumber(nutrition.protein)}g protein';

    return ScannerRecipeCard(
      recipeId: recipe.recipeId,
      title: recipe.title,
      meta: meta,
      tags: recipe.dietTypes.map(_dietLabel).toList(),
      palette: palette,
      imageUrl: recipe.imageUrl,
    );
  }

  final int recipeId;
  final String title;
  final String meta;
  final List<String> tags;
  final MealPalette palette;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRecipeDetails(context, recipeId, title),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 8),
              color: AppColors.darkGreen.withValues(alpha: .04),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 172,
              child: RecipeApiImage(imageUrl: imageUrl, palette: palette),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final tag in tags) IngredientTag(tag)],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailsScreen(
                            recipeId: recipeId,
                            recipeTitle: title,
                          ),
                        ),
                      ),
                      child: const Text('Xem công thức →'),
                    ),
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

class ApiScannerRecipeList extends StatelessWidget {
  const ApiScannerRecipeList({
    super.key,
    required this.future,
    required this.onRetry,
  });

  final Future<List<Recipe>> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: future,
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
            message: 'Không thể tải công thức theo nguyên liệu.',
            isError: true,
            actionLabel: 'Thử lại',
            onAction: onRetry,
          );
        }

        final recipes = snapshot.data ?? const [];
        if (recipes.isEmpty) {
          return const ApiMessageBanner(
            message: 'Chưa có công thức phù hợp từ recipe-service.',
          );
        }

        return Column(
          children: [
            for (var index = 0; index < recipes.length; index++) ...[
              ScannerRecipeCard.fromRecipe(
                recipe: recipes[index],
                palette: _paletteForIndex(index),
              ),
              if (index != recipes.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}
