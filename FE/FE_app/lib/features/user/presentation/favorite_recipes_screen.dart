part of '../../../app.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  late Future<List<Recipe>> _recipesFuture = _loadRecipes();

  Future<List<Recipe>> _loadRecipes() async {
    final store = AuthDependencies.instance.favoriteStore;
    await store.load(force: true);
    final recipes = await Future.wait(
      store.recipeIds.map((recipeId) async {
        try {
          return await store.recipeRepository.getRecipe(recipeId);
        } catch (_) {
          return null;
        }
      }),
    );
    return recipes.whereType<Recipe>().toList();
  }

  void _refresh() {
    setState(() => _recipesFuture = _loadRecipes());
  }

  @override
  Widget build(BuildContext context) {
    final store = AuthDependencies.instance.favoriteStore;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Món yêu thích',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return FutureBuilder<List<Recipe>>(
            future: _recipesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Không thể tải danh sách món yêu thích.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _refresh,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final recipes = (snapshot.data ?? const <Recipe>[])
                  .where((recipe) => store.isFavorite(recipe.recipeId))
                  .toList();
              if (recipes.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 54,
                          color: AppColors.green,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Bạn chưa lưu món yêu thích nào.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                itemCount: recipes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    RecipeRecommendationCard.fromRecipe(
                      recipe: recipes[index],
                      palette: _paletteForIndex(index),
                    ),
              );
            },
          );
        },
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.recipeId});

  final int recipeId;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  void initState() {
    super.initState();
    Future.microtask(AuthDependencies.instance.favoriteStore.load);
  }

  Future<void> _toggle() async {
    try {
      await AuthDependencies.instance.favoriteStore.toggle(widget.recipeId);
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException
          ? error.message
          : 'Không thể cập nhật món yêu thích.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AuthDependencies.instance.favoriteStore;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final selected = store.isFavorite(widget.recipeId);
        final pending = store.isPending(widget.recipeId);
        return CircleAvatar(
          radius: 23,
          backgroundColor: Colors.white.withValues(alpha: .94),
          child: IconButton(
            tooltip: selected ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
            onPressed: pending ? null : _toggle,
            icon: pending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.green,
                    ),
                  )
                : Icon(
                    selected ? Icons.favorite : Icons.favorite_border,
                    color: selected ? Colors.redAccent : AppColors.darkGreen,
                  ),
          ),
        );
      },
    );
  }
}
