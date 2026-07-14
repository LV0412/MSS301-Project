part of '../../../app.dart';

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, this.recipeId, this.recipeTitle});

  final int? recipeId;
  final String? recipeTitle;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Future<Recipe> _recipeFuture = _loadRecipe();

  Future<Recipe> _loadRecipe() async {
    final repository = AuthDependencies.instance.recipeRepository;
    var recipeId = widget.recipeId;
    if (recipeId == null) {
      final recipes = await repository.getRecipes(size: 1);
      if (recipes.isEmpty) {
        throw const ApiException(
          message: 'Recipe service chưa có dữ liệu công thức.',
        );
      }
      recipeId = recipes.first.recipeId;
    }
    return repository.getRecipe(recipeId);
  }

  void _retry() {
    setState(() => _recipeFuture = _loadRecipe());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            FutureBuilder<Recipe>(
              future: _recipeFuture,
              builder: (context, snapshot) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
                  children: [
                    const RecipeDetailsHeader(),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 120),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.green,
                          ),
                        ),
                      )
                    else if (snapshot.hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            Text(
                              snapshot.error is ApiException
                                  ? (snapshot.error! as ApiException).message
                                  : 'Không thể tải chi tiết công thức.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _retry,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._buildRecipeContent(snapshot.requireData),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecipeContent(Recipe recipe) {
    final steps = [...recipe.steps]
      ..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
    return [
      RecipeHeroPanel(recipe: recipe),
      const SizedBox(height: 18),
      RecipeMetaLine(recipe: recipe),
      const SizedBox(height: 18),
      NutritionFactsCard(
        key: ValueKey(recipe.nutrition?.nutritionId),
        nutrition: recipe.nutrition,
      ),
      const SizedBox(height: 22),
      IngredientsCard(recipe: recipe),
      const SizedBox(height: 26),
      const Text(
        'Hướng dẫn nấu ăn',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
      const SizedBox(height: 22),
      if (steps.isEmpty)
        const ApiMessageBanner(message: 'Công thức chưa có bước hướng dẫn.')
      else
        for (final step in steps)
          CookingStep(
            key: ValueKey(step.stepId ?? step.stepOrder),
            step: '${step.stepOrder}',
            title: 'Bước ${step.stepOrder}',
            body: step.instruction,
          ),
      const SizedBox(height: 20),
    ];
  }
}
