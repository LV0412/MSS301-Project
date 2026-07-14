part of '../../../app.dart';

class PersonalizedSuggestionsScreen extends StatelessWidget {
  const PersonalizedSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 110),
              children: [
                const HomeHeader(),
                const SizedBox(height: 30),
                const Text(
                  'Công thức mới',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Danh sách mới nhất từ Recipe Service',
                  style: TextStyle(fontSize: 15, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 24),
                const ApiSuggestionRecipeList(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.explore),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedSuggestionCard extends StatelessWidget {
  const FeaturedSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: AppColors.darkGreen.withValues(alpha: .06),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const MealArt(palette: MealPalette.lunch),
                Positioned(
                  left: 18,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LỰA CHỌN TỐI ƯU',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: .6,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phù hợp 98%',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w300,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Salmon Bowl Chống Oxy\nHóa',
                  style: TextStyle(
                    fontSize: 21,
                    height: 1.16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Món ăn này giúp bạn đạt 70% mục tiêu Protein trong ngày mà vẫn giữ mức Natri thấp.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: NutritionChip(label: 'CALO', value: '450'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: NutritionChip(label: 'PRO', value: '32g'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: NutritionChip(label: 'CARB', value: '24g'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: NutritionChip(label: 'FAT', value: '18g'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecipeDetailsScreen(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'XEM CÔNG THỨC CHI TIẾT',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: .4,
                        fontWeight: FontWeight.w900,
                      ),
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

class NutritionChip extends StatelessWidget {
  const NutritionChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: .6,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionMiniCard extends StatelessWidget {
  const SuggestionMiniCard({
    super.key,
    required this.recipeId,
    required this.title,
    required this.tags,
    required this.calories,
    required this.time,
    required this.palette,
    this.imageUrl,
  });

  factory SuggestionMiniCard.fromRecipe({
    required Recipe recipe,
    required MealPalette palette,
  }) {
    final nutrition = recipe.nutrition;
    final tags = recipe.dietTypes.isEmpty
        ? ['RECIPE API']
        : recipe.dietTypes.map(_dietLabel).toList();

    return SuggestionMiniCard(
      recipeId: recipe.recipeId,
      title: recipe.title,
      tags: tags,
      calories: nutrition == null ? '-' : _formatNumber(nutrition.calories),
      time: '${recipe.totalMinutes}’',
      palette: palette,
      imageUrl: recipe.imageUrl,
    );
  }

  final int recipeId;
  final String title;
  final List<String> tags;
  final String calories;
  final String time;
  final MealPalette palette;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RecipeDetailsScreen(recipeId: recipeId, recipeTitle: title),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
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
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeApiImage(imageUrl: imageUrl, palette: palette),
                  Positioned(
                    left: 12,
                    top: 10,
                    child: FavoriteButton(recipeId: recipeId),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [for (final tag in tags) ExploreTag(label: tag)],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.line, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _TinyMetric(label: 'CAL', value: calories),
                      const SizedBox(width: 28),
                      _TinyMetric(label: 'TIME', value: time),
                      const Spacer(),
                      FoodLogButton(
                        recipeId: recipeId,
                        recipeTitle: title,
                        compact: true,
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.green),
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

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
      ],
    );
  }
}

class ApiSuggestionRecipeList extends StatefulWidget {
  const ApiSuggestionRecipeList({super.key});

  @override
  State<ApiSuggestionRecipeList> createState() =>
      _ApiSuggestionRecipeListState();
}

class _ApiSuggestionRecipeListState extends State<ApiSuggestionRecipeList> {
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
            message: 'Chưa có công thức từ recipe-service.',
          );
        }

        return Column(
          children: [
            for (var index = 0; index < recipes.length; index++) ...[
              SuggestionMiniCard.fromRecipe(
                recipe: recipes[index],
                palette: _paletteForIndex(index),
              ),
              if (index != recipes.length - 1) const SizedBox(height: 22),
            ],
          ],
        );
      },
    );
  }
}

class SuggestionsAnalysisCard extends StatelessWidget {
  const SuggestionsAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights, color: AppColors.green),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân tích từ AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Các công thức này được tối ưu hóa để giảm lượng Carbohydrate tinh chế trong thực đơn của bạn, phù hợp với mục tiêu cải thiện độ nhạy Insulin. Bạn sẽ cảm thấy tràn đầy năng lượng hơn vào buổi chiều sau khi dùng các bữa này.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.48,
                    color: AppColors.darkGreen,
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
