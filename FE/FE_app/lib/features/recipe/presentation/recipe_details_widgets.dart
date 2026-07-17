part of '../../../app.dart';

class RecipeDetailsHeader extends StatelessWidget {
  const RecipeDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 18),
        ),
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
      ],
    );
  }
}

class RecipeHeroPanel extends StatelessWidget {
  const RecipeHeroPanel({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 212,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RecipeApiImage(
                  imageUrl: recipe.imageUrl,
                  palette: MealPalette.lunch,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.dietTypes.isEmpty
              ? const [ExploreTag(label: 'CÔNG THỨC')]
              : recipe.dietTypes
                    .map((diet) => ExploreTag(label: _dietLabel(diet)))
                    .toList(),
        ),
        const SizedBox(height: 10),
        Text(
          recipe.title,
          style: TextStyle(
            fontSize: 26,
            height: 1.04,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class RecipeMetaLine extends StatelessWidget {
  const RecipeMetaLine({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.darkGreen),
            const SizedBox(width: 5),
            Text(
              '${recipe.totalMinutes} phút',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 14),
            const Icon(
              Icons.restaurant_menu,
              size: 16,
              color: AppColors.darkGreen,
            ),
            const SizedBox(width: 5),
            Text(
              _difficultyLabel(recipe.difficulty),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 14),
            const Icon(
              Icons.people_outline,
              size: 16,
              color: AppColors.darkGreen,
            ),
            const SizedBox(width: 5),
            Text(
              '${recipe.servings} khẩu phần',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            FoodLogButton(recipeId: recipe.recipeId, recipeTitle: recipe.title),
            const SizedBox(width: 12),
            FavoriteButton(recipeId: recipe.recipeId),
          ],
        ),
        if (recipe.updatedAt != null || recipe.createdAt != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cập nhật ${_formatRecipeDate(recipe.updatedAt ?? recipe.createdAt!)}',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
        ],
      ],
    );
  }
}

class DetailAiInsightCard extends StatelessWidget {
  const DetailAiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.green),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_outlined, color: AppColors.green, size: 18),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Insight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Công thức này phù hợp với mục tiêu ăn nhiều protein của bạn. Chứa hàm lượng Omega-3 cao từ cá hồi và chất béo tốt từ bơ giúp hỗ trợ phục hồi cơ bắp sau buổi tập sáng nay của bạn.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.muted,
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

class NutritionFactsCard extends StatelessWidget {
  const NutritionFactsCard({super.key, required this.nutrition});

  final RecipeNutrition? nutrition;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Nutrition Facts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'PER SERVING',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: .6,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (nutrition == null)
            const ApiMessageBanner(message: 'Chưa có dữ liệu dinh dưỡng.')
          else ...[
            Row(
              children: [
                Expanded(
                  child: FactBar(
                    label: 'CALORIES',
                    value: '${_formatNumber(nutrition!.calories)} kcal',
                    progress: (nutrition!.calories / 600)
                        .clamp(0, 1)
                        .toDouble(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FactBar(
                    label: 'PROTEIN',
                    value: '${_formatNumber(nutrition!.protein)}g',
                    progress: (nutrition!.protein / 50).clamp(0, 1).toDouble(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FactBar(
                    label: 'CARBS',
                    value: '${_formatNumber(nutrition!.carbs)}g',
                    progress: (nutrition!.carbs / 75).clamp(0, 1).toDouble(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FactBar(
                    label: 'FAT',
                    value: '${_formatNumber(nutrition!.fat)}g',
                    progress: (nutrition!.fat / 40).clamp(0, 1).toDouble(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _FactSmall(
                    label: 'Fiber',
                    value: '${_formatNumber(nutrition!.fiber)}g',
                  ),
                ),
                Expanded(
                  child: _FactSmall(
                    label: 'Sodium',
                    value: '${_formatNumber(nutrition!.sodium)}mg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FactSmall(
                    label: 'Sugar',
                    value: '${_formatNumber(nutrition!.sugar)}g',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class FactBar extends StatelessWidget {
  const FactBar({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.muted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: AppColors.green,
            backgroundColor: AppColors.line,
          ),
        ),
      ],
    );
  }
}

class _FactSmall extends StatelessWidget {
  const _FactSmall({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class IngredientsCard extends StatelessWidget {
  const IngredientsCard({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              ExploreTag(label: '${recipe.servings} KHẨU PHẦN'),
            ],
          ),
          const SizedBox(height: 16),
          if (recipe.ingredients.isEmpty)
            const ApiMessageBanner(message: 'Công thức chưa có nguyên liệu.')
          else
            for (final ingredient in recipe.ingredients) ...[
              IngredientRow(
                key: ValueKey(ingredient.ingredientId ?? ingredient.name),
                icon: Icons.restaurant_outlined,
                name: ingredient.name,
                amount: _ingredientAmount(ingredient),
                alert: ingredient.allergens.isNotEmpty,
              ),
              if (ingredient.allergens.isNotEmpty)
                AllergyNote(
                  allergenNames: ingredient.allergens
                      .map((allergen) => allergen.name)
                      .where((name) => name.isNotEmpty)
                      .toList(),
                ),
            ],
        ],
      ),
    );
  }

  static String _ingredientAmount(RecipeIngredient ingredient) {
    final quantity = ingredient.quantity;
    final amount = quantity == null ? '' : _formatNumber(quantity);
    return [
      amount,
      ingredient.unit,
    ].where((part) => part.trim().isNotEmpty).join(' ');
  }
}

class IngredientRow extends StatelessWidget {
  const IngredientRow({
    super.key,
    required this.icon,
    required this.name,
    required this.amount,
    this.alert = false,
  });

  final IconData icon;
  final String name;
  final String amount;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Icon(
            alert ? Icons.info_outline : Icons.check_circle_outline,
            size: 17,
            color: alert ? const Color(0xFFA36E30) : AppColors.green,
          ),
        ],
      ),
    );
  }
}

class AllergyNote extends StatelessWidget {
  const AllergyNote({super.key, required this.allergenNames});

  final List<String> allergenNames;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 48, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        allergenNames.isEmpty
            ? '⚠ Nguyên liệu có thông tin dị ứng.'
            : '⚠ Có thể chứa: ${allergenNames.join(', ')}',
        style: const TextStyle(
          fontSize: 9,
          height: 1.25,
          fontWeight: FontWeight.w900,
          color: Color(0xFF774B24),
        ),
      ),
    );
  }
}

class CookingStep extends StatelessWidget {
  const CookingStep({
    super.key,
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 34),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.green,
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.52,
                    color: AppColors.muted,
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

class MealFeedbackCard extends StatelessWidget {
  const MealFeedbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How was your meal?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your feedback helps NutriChef AI refine your future recommendations.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white.withValues(alpha: .65),
                    child: const Icon(
                      Icons.star_border,
                      size: 17,
                      color: AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 72,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Share your experience (Optional)...',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
