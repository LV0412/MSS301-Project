part of '../../../app.dart';

class RecipeSearchBox extends StatelessWidget {
  const RecipeSearchBox({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: AppColors.darkGreen),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Tìm công thức, nguyên liệu...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Xóa tìm kiếm',
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 20),
            ),
        ],
      ),
    );
  }
}

class RecipeFilters extends StatelessWidget {
  const RecipeFilters({
    super.key,
    required this.selectedDietType,
    required this.advancedFilterCount,
    required this.onDietSelected,
    required this.onAdvancedPressed,
    required this.onReset,
  });

  final String? selectedDietType;
  final int advancedFilterCount;
  final ValueChanged<String?> onDietSelected;
  final VoidCallback onAdvancedPressed;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final filters = [
      (
        Icons.tune,
        advancedFilterCount == 0 ? 'Bộ lọc' : 'Bộ lọc ($advancedFilterCount)',
        null,
      ),
      (Icons.bolt_outlined, 'Keto', 'KETO'),
      (Icons.eco_outlined, 'Chay', 'VEGETARIAN'),
      (Icons.restart_alt, 'Đặt lại', 'RESET'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter.$3 != null && filter.$3 == selectedDietType;
          final highlighted =
              selected || (index == 0 && advancedFilterCount > 0);
          return InkWell(
            borderRadius: BorderRadius.circular(99),
            onTap: () {
              if (index == 0) {
                onAdvancedPressed();
              } else if (filter.$3 == 'RESET') {
                onReset();
              } else {
                onDietSelected(filter.$3);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: highlighted ? AppColors.green : AppColors.sand,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  Icon(
                    filter.$1,
                    size: 16,
                    color: highlighted ? Colors.white : AppColors.darkGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: highlighted ? Colors.white : AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecipeAdvancedFilters {
  const _RecipeAdvancedFilters({
    this.categoryId,
    this.ingredientIds = const [],
    this.ingredient,
    this.minCalories,
    this.maxCalories,
    this.excludedAllergenIds = const [],
    this.sort = 'createdAt,desc',
  });

  final int? categoryId;
  final List<int> ingredientIds;
  final String? ingredient;
  final double? minCalories;
  final double? maxCalories;
  final List<int> excludedAllergenIds;
  final String sort;

  int get activeCount => [
    categoryId != null,
    ingredientIds.isNotEmpty,
    ingredient?.trim().isNotEmpty == true,
    minCalories != null,
    maxCalories != null,
    excludedAllergenIds.isNotEmpty,
    sort != 'createdAt,desc',
  ].where((active) => active).length;
}

class _CatalogOption {
  const _CatalogOption({required this.id, required this.name});
  final int id;
  final String name;
}

class _RecipeFilterCatalogs {
  const _RecipeFilterCatalogs({
    this.categories = const [],
    this.ingredients = const [],
    this.allergens = const [],
  });
  final List<_CatalogOption> categories;
  final List<_CatalogOption> ingredients;
  final List<_CatalogOption> allergens;
}

class _RecipeAdvancedFiltersSheet extends StatefulWidget {
  const _RecipeAdvancedFiltersSheet({
    required this.initial,
    required this.catalogs,
  });

  final _RecipeAdvancedFilters initial;
  final _RecipeFilterCatalogs catalogs;

  @override
  State<_RecipeAdvancedFiltersSheet> createState() =>
      _RecipeAdvancedFiltersSheetState();
}

class _RecipeAdvancedFiltersSheetState
    extends State<_RecipeAdvancedFiltersSheet> {
  late final TextEditingController _ingredientController;
  late final TextEditingController _minCaloriesController;
  late final TextEditingController _maxCaloriesController;
  late int? _categoryId;
  late Set<int> _ingredientIds;
  late Set<int> _excludedAllergenIds;
  late String _sort;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _categoryId = initial.categoryId;
    _ingredientIds = initial.ingredientIds.toSet();
    _excludedAllergenIds = initial.excludedAllergenIds.toSet();
    _ingredientController = TextEditingController(
      text: initial.ingredient ?? '',
    );
    _minCaloriesController = TextEditingController(
      text: initial.minCalories?.toString() ?? '',
    );
    _maxCaloriesController = TextEditingController(
      text: initial.maxCalories?.toString() ?? '',
    );
    _sort = initial.sort;
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _minCaloriesController.dispose();
    _maxCaloriesController.dispose();
    super.dispose();
  }

  void _apply() {
    final minCalories = double.tryParse(_minCaloriesController.text.trim());
    final maxCalories = double.tryParse(_maxCaloriesController.text.trim());
    if (minCalories != null &&
        maxCalories != null &&
        minCalories > maxCalories) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Năng lượng tối thiểu không được lớn hơn năng lượng tối đa.',
          ),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      _RecipeAdvancedFilters(
        categoryId: _categoryId,
        ingredientIds: _ingredientIds.toList(),
        ingredient: _emptyToNull(_ingredientController.text),
        minCalories: minCalories,
        maxCalories: maxCalories,
        excludedAllergenIds: _excludedAllergenIds.toList(),
        sort: _sort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bộ lọc công thức',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: _categoryId ?? 0,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  filled: true,
                  fillColor: AppColors.field,
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Tất cả danh mục'),
                  ),
                  for (final option in widget.catalogs.categories)
                    DropdownMenuItem<int>(
                      value: option.id,
                      child: Text(option.name),
                    ),
                ],
                onChanged: (value) => setState(
                  () =>
                      _categoryId = value == null || value == 0 ? null : value,
                ),
              ),
              const SizedBox(height: 14),
              _catalogSelector(
                title: 'Nguyên liệu',
                options: widget.catalogs.ingredients,
                selectedIds: _ingredientIds,
                onChanged: (ids) => setState(() => _ingredientIds = ids),
              ),
              _filterField(
                controller: _ingredientController,
                label: 'Tên nguyên liệu',
                hint: 'Ví dụ: thịt gà',
              ),
              Row(
                children: [
                  Expanded(
                    child: _filterField(
                      controller: _minCaloriesController,
                      label: 'Năng lượng tối thiểu (kcal)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _filterField(
                      controller: _maxCaloriesController,
                      label: 'Năng lượng tối đa (kcal)',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              _catalogSelector(
                title: 'Loại trừ chất gây dị ứng',
                options: widget.catalogs.allergens,
                selectedIds: _excludedAllergenIds,
                onChanged: (ids) => setState(() => _excludedAllergenIds = ids),
              ),
              const Text(
                'Sắp xếp',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _sort,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: AppColors.field,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'createdAt,desc',
                    child: Text('Mới nhất'),
                  ),
                  DropdownMenuItem(
                    value: 'createdAt,asc',
                    child: Text('Cũ nhất'),
                  ),
                  DropdownMenuItem(value: 'title,asc', child: Text('Tên A–Z')),
                  DropdownMenuItem(value: 'title,desc', child: Text('Tên Z–A')),
                ],
                onChanged: (value) => setState(() => _sort = value ?? _sort),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        const _RecipeAdvancedFilters(),
                      ),
                      child: const Text('Xóa bộ lọc'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: AppColors.field,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _catalogSelector({
    required String title,
    required List<_CatalogOption> options,
    required Set<int> selectedIds,
    required ValueChanged<Set<int>> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          selectedIds.isEmpty ? title : '$title (${selectedIds.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in options)
                  FilterChip(
                    label: Text(option.name),
                    selected: selectedIds.contains(option.id),
                    onSelected: (selected) {
                      final next = {...selectedIds};
                      selected ? next.add(option.id) : next.remove(option.id);
                      onChanged(next);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class HotPickCard extends StatelessWidget {
  const HotPickCard({
    super.key,
    required this.label,
    required this.title,
    required this.palette,
    this.recipeId,
    this.imageUrl,
  });

  factory HotPickCard.fromRecipe({
    required Recipe recipe,
    required MealPalette palette,
  }) {
    return HotPickCard(
      recipeId: recipe.recipeId,
      label: recipe.categoryName ?? 'RECIPE SERVICE',
      title: recipe.title,
      palette: palette,
      imageUrl: recipe.imageUrl,
    );
  }

  final String label;
  final String title;
  final MealPalette palette;
  final int? recipeId;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: recipeId == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailsScreen(recipeId: recipeId),
              ),
            ),
      child: Container(
        height: 286,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 9),
              color: Colors.black.withValues(alpha: .18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RecipeApiImage(imageUrl: imageUrl, palette: palette),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExploreTag(label: label, dark: true),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.32,
                      fontWeight: FontWeight.w800,
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

class RecommendedHeader extends StatelessWidget {
  const RecommendedHeader({super.key, this.totalElements = 0});

  final int totalElements;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Gợi ý cho bạn',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const Spacer(),
        Text(
          '$totalElements kết quả',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
      ],
    );
  }
}

class RecipeRecommendationCard extends StatelessWidget {
  const RecipeRecommendationCard({
    super.key,
    required this.recipeId,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.time,
    required this.palette,
    required this.tags,
    this.imageUrl,
  });

  factory RecipeRecommendationCard.fromRecipe({
    required Recipe recipe,
    required MealPalette palette,
  }) {
    final nutrition = recipe.nutrition;
    final calories = nutrition == null
        ? '- kcal'
        : '${_formatNumber(nutrition.calories)} kcal';
    final tags = recipe.dietTypes.isEmpty
        ? ['Recipe API']
        : recipe.dietTypes.map(_dietLabel).toList();

    return RecipeRecommendationCard(
      recipeId: recipe.recipeId,
      title: recipe.title,
      subtitle:
          '${recipe.categoryName ?? 'Recipe service'} • ${_difficultyLabel(recipe.difficulty)}',
      calories: calories,
      time: '${recipe.totalMinutes} phút',
      palette: palette,
      tags: tags,
      imageUrl: recipe.imageUrl,
    );
  }

  final int recipeId;
  final String title;
  final String subtitle;
  final String calories;
  final String time;
  final MealPalette palette;
  final List<String> tags;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openRecipeDetails(context, recipeId, title),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
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
              height: 188,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RecipeApiImage(imageUrl: imageUrl, palette: palette),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: FavoriteButton(recipeId: recipeId),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final tag in tags) ExploreTag(label: tag),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 15, color: AppColors.ink),
                  ),
                  const SizedBox(height: 22),
                  const Divider(color: AppColors.line, height: 1),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_outlined,
                        size: 17,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(width: 28),
                      const Icon(
                        Icons.schedule,
                        size: 17,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const Spacer(),
                      FoodLogButton(
                        recipeId: recipeId,
                        recipeTitle: title,
                        compact: true,
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

class ApiRecipeRecommendationList extends StatelessWidget {
  const ApiRecipeRecommendationList({
    super.key,
    required this.recipes,
    required this.isLoading,
    required this.hasError,
    required this.isFirstPage,
    required this.lastPage,
    required this.onRetry,
    required this.onLoadMore,
  });

  final List<Recipe> recipes;
  final bool isLoading;
  final bool hasError;
  final bool isFirstPage;
  final bool lastPage;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading && recipes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }
    if (hasError && recipes.isEmpty) {
      return Column(
        children: [
          const ApiMessageBanner(message: 'Không thể tải danh sách công thức.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      );
    }
    if (recipes.isEmpty) {
      return const ApiMessageBanner(
        message: 'Không tìm thấy công thức phù hợp với bộ lọc.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < recipes.length; index++) ...[
          RecipeRecommendationCard.fromRecipe(
            recipe: recipes[index],
            palette: _paletteForIndex(index),
          ),
          if (index != recipes.length - 1) const SizedBox(height: 20),
        ],
        if (!lastPage || isLoading || hasError) ...[
          const SizedBox(height: 20),
          if (isLoading)
            const CircularProgressIndicator(color: AppColors.green)
          else if (hasError && !isFirstPage)
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Thử tải trang tiếp theo'),
            )
          else
            OutlinedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more),
              label: const Text('Tải thêm'),
            ),
        ],
      ],
    );
  }
}

class ExploreTag extends StatelessWidget {
  const ExploreTag({super.key, required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: .25)
            : AppColors.field.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!dark) ...[
            const Icon(Icons.favorite_border, size: 13, color: AppColors.green),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: dark ? .7 : 0,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreInsightCard extends StatelessWidget {
  const ExploreInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
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
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFDDE0CF),
            child: Icon(Icons.auto_awesome, color: AppColors.green),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NutriChef AI Insight',
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Dựa trên thói quen của bạn, chúng tôi đề xuất tăng thêm 15g protein cho bữa tối hôm nay để hỗ trợ phục hồi sau buổi tập.',
                  style: TextStyle(
                    fontSize: 15,
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
