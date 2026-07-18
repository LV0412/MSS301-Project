part of '../../../app.dart';

class ExploreRecipesScreen extends StatefulWidget {
  const ExploreRecipesScreen({super.key, this.onTabSelected});

  final ValueChanged<HomeTab>? onTabSelected;

  @override
  State<ExploreRecipesScreen> createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<Recipe> _recipes = const [];
  String? _dietType;
  _RecipeAdvancedFilters _advancedFilters = const _RecipeAdvancedFilters();
  int _page = -1;
  int _totalElements = 0;
  int _requestId = 0;
  bool _lastPage = false;
  bool _isLoading = false;
  bool _isCatalogLoading = false;
  _RecipeFilterCatalogs _catalogs = const _RecipeFilterCatalogs();
  Object? _catalogError;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadRecipes(reset: true);
    _loadCatalogs();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _loadRecipes(reset: true),
    );
    setState(() {});
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _loadRecipes(reset: true);
  }

  void _selectDiet(String? dietType) {
    setState(() => _dietType = _dietType == dietType ? null : dietType);
    _loadRecipes(reset: true);
  }

  Future<void> _openAdvancedFilters() async {
    if (_isCatalogLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải danh mục bộ lọc...')),
      );
      return;
    }
    if (_catalogError != null) {
      await _loadCatalogs();
      if (!mounted || _catalogError != null) return;
    }
    final result = await showModalBottomSheet<_RecipeAdvancedFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (_) => _RecipeAdvancedFiltersSheet(
        initial: _advancedFilters,
        catalogs: _catalogs,
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _advancedFilters = result);
    await _loadRecipes(reset: true);
  }

  Future<void> _loadCatalogs() async {
    setState(() {
      _isCatalogLoading = true;
      _catalogError = null;
    });
    try {
      final repository = AuthDependencies.instance.recipeRepository;
      final results = await Future.wait([
        repository.getCategories(),
        repository.getIngredients(),
        repository.getAllergens(),
      ]);
      if (!mounted) return;
      setState(() {
        _catalogs = _RecipeFilterCatalogs(
          categories: _catalogOptions(
            results[0],
            'categoryId',
            labelBuilder: _recipeCategoryLabel,
          ),
          ingredients: _catalogOptions(results[1], 'ingredientId'),
          allergens: _catalogOptions(results[2], 'allergenId'),
        );
        _isCatalogLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _catalogError = error;
        _isCatalogLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải danh mục bộ lọc.')),
      );
    }
  }

  static List<_CatalogOption> _catalogOptions(
    List<Map<String, dynamic>> items,
    String idKey, {
    String Function(String)? labelBuilder,
  }) {
    return items
        .map(
          (item) => _CatalogOption(
            id: (item[idKey] as num).toInt(),
            name:
                labelBuilder?.call(item['name']?.toString() ?? '') ??
                item['name']?.toString() ??
                '',
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  static String _recipeCategoryLabel(String value) {
    final normalized = value.trim().toUpperCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    return switch (normalized) {
      'BREAKFAST' || 'BREAKFASTS' => 'Bữa sáng',
      'BRUNCH' => 'Bữa sáng muộn',
      'LUNCH' || 'LUNCHES' => 'Bữa trưa',
      'DINNER' || 'DINNERS' => 'Bữa tối',
      'SNACK' || 'SNACKS' => 'Bữa phụ',
      'APPETIZER' || 'APPETIZERS' || 'STARTER' || 'STARTERS' => 'Món khai vị',
      'MAIN_COURSE' || 'MAIN_DISH' => 'Món chính',
      'DESSERT' || 'DESSERTS' => 'Món tráng miệng',
      'DRINK' || 'DRINKS' || 'BEVERAGE' || 'BEVERAGES' => 'Đồ uống',
      'SOUP' || 'SOUPS' => 'Canh và súp',
      'SALAD' || 'SALADS' => 'Salad',
      'OTHER' => 'Khác',
      _ => value,
    };
  }

  void _resetFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _dietType = null;
      _advancedFilters = const _RecipeAdvancedFilters();
    });
    _loadRecipes(reset: true);
  }

  Future<void> _loadRecipes({required bool reset}) async {
    if (_isLoading && !reset) return;
    final requestId = ++_requestId;
    final requestedPage = reset ? 0 : _page + 1;
    setState(() {
      _isLoading = true;
      _error = null;
      if (reset) {
        _lastPage = false;
      }
    });

    try {
      final result = await AuthDependencies.instance.recipeRepository
          .searchRecipes(
            page: requestedPage,
            size: 6,
            query: _searchController.text,
            categoryId: _advancedFilters.categoryId,
            ingredientIds: _advancedFilters.ingredientIds,
            ingredient: _advancedFilters.ingredient,
            minCalories: _advancedFilters.minCalories,
            maxCalories: _advancedFilters.maxCalories,
            dietType: _dietType,
            excludedAllergenIds: _advancedFilters.excludedAllergenIds,
            sort: _advancedFilters.sort,
          );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _recipes = _mergeUniqueRecipes(
          reset ? result.content : [..._recipes, ...result.content],
        );
        _page = result.page;
        _totalElements = result.totalElements;
        _lastPage = result.last;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  static List<Recipe> _mergeUniqueRecipes(Iterable<Recipe> recipes) {
    final uniqueById = <int, Recipe>{};
    for (final recipe in recipes) {
      uniqueById.putIfAbsent(recipe.recipeId, () => recipe);
    }
    return uniqueById.values.toList(growable: false);
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: [
                const HomeHeader(),
                const SizedBox(height: 24),
                RecipeSearchBox(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
                const SizedBox(height: 18),
                RecipeFilters(
                  selectedDietType: _dietType,
                  advancedFilterCount: _advancedFilters.activeCount,
                  onDietSelected: _selectDiet,
                  onAdvancedPressed: _openAdvancedFilters,
                  onReset: _resetFilters,
                ),
                const SizedBox(height: 28),
                if (_recipes.isNotEmpty) ...[
                  const Text(
                    'Món nổi bật',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (
                    var index = 0;
                    index < _recipes.take(2).length;
                    index++
                  ) ...[
                    HotPickCard.fromRecipe(
                      recipe: _recipes[index],
                      palette: _paletteForIndex(index),
                    ),
                    if (index != _recipes.take(2).length - 1)
                      const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 64),
                ],
                RecommendedHeader(totalElements: _totalElements),
                const SizedBox(height: 14),
                ApiRecipeRecommendationList(
                  recipes: _recipes,
                  isLoading: _isLoading,
                  hasError: _error != null,
                  isFirstPage: _recipes.isEmpty,
                  lastPage: _lastPage,
                  onRetry: () => _loadRecipes(reset: _recipes.isEmpty),
                  onLoadMore: () => _loadRecipes(reset: false),
                ),
                const SizedBox(height: 78),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(
                selected: HomeTab.explore,
                onSelected: widget.onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
