import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_api_client.dart';
import 'models/recipe.dart';

class RecipeRepository {
  RecipeRepository({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;

  Future<List<Recipe>> getRecipes({
    int page = 0,
    int size = 20,
    String? query,
    int? categoryId,
    List<int> ingredientIds = const [],
    String? ingredient,
    double? minCalories,
    double? maxCalories,
    String? dietType,
    List<int> excludedAllergenIds = const [],
    String? sort,
  }) async {
    final result = await searchRecipes(
      page: page,
      size: size,
      query: query,
      categoryId: categoryId,
      ingredientIds: ingredientIds,
      ingredient: ingredient,
      minCalories: minCalories,
      maxCalories: maxCalories,
      dietType: dietType,
      excludedAllergenIds: excludedAllergenIds,
      sort: sort,
    );
    return result.content;
  }

  Future<RecipePage> searchRecipes({
    int page = 0,
    int size = 20,
    String? query,
    int? categoryId,
    List<int> ingredientIds = const [],
    String? ingredient,
    double? minCalories,
    double? maxCalories,
    String? dietType,
    List<int> excludedAllergenIds = const [],
    String? sort,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
      if (_hasText(query)) 'query': query!.trim(),
      'categoryId': ?categoryId,
      if (ingredientIds.isNotEmpty) 'ingredientIds': ingredientIds,
      if (_hasText(ingredient)) 'ingredient': ingredient!.trim(),
      'minCalories': ?minCalories,
      'maxCalories': ?maxCalories,
      if (_hasText(dietType)) 'dietType': dietType,
      if (excludedAllergenIds.isNotEmpty)
        'excludedAllergenIds': excludedAllergenIds,
      'sort': _stableSort(sort),
    };
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>(
        '/recipes',
        queryParameters: queryParameters,
      ),
    );

    final data = response.data;
    final content = data?['content'];
    final recipes = content is List
        ? content
              .whereType<Map>()
              .map(
                (item) => Recipe.fromJson(
                  item.map((key, value) => MapEntry('$key', value)),
                ),
              )
              .toList()
        : const <Recipe>[];

    return RecipePage(
      content: recipes,
      page: (data?['number'] as num?)?.toInt() ?? page,
      totalPages: (data?['totalPages'] as num?)?.toInt() ?? 0,
      totalElements:
          (data?['totalElements'] as num?)?.toInt() ?? recipes.length,
      last: data?['last'] as bool? ?? recipes.length < size,
    );
  }

  Future<List<Map<String, dynamic>>> getAllergens({int size = 100}) async {
    return _getCatalog('/allergens', size: size);
  }

  Future<List<Map<String, dynamic>>> getCategories({int size = 100}) {
    return _getCatalog('/categories', size: size);
  }

  Future<List<Map<String, dynamic>>> getIngredients({int size = 200}) {
    return _getCatalog('/ingredients', size: size);
  }

  Future<List<Map<String, dynamic>>> _getCatalog(
    String path, {
    required int size,
  }) async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {'page': 0, 'size': size, 'sort': 'name,asc'},
      ),
    );
    final content = response.data?['content'];
    if (content is! List) return const [];

    return content
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();
  }

  Future<Recipe> getRecipe(int recipeId) async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>('/recipes/$recipeId'),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Recipe service không trả dữ liệu.');
    }
    return Recipe.fromJson(data);
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  static bool _hasText(String? value) => value?.trim().isNotEmpty == true;

  static List<String> _stableSort(String? sort) {
    final primary = _hasText(sort) ? sort!.trim() : 'createdAt,desc';
    final parts = primary.split(',');
    final property = parts.first.trim();
    if (property == 'recipeId') return [primary];

    final direction = parts.length > 1 && parts.last.toLowerCase() == 'asc'
        ? 'asc'
        : 'desc';
    return [primary, 'recipeId,$direction'];
  }
}

class RecipePage {
  const RecipePage({
    required this.content,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  final List<Recipe> content;
  final int page;
  final int totalPages;
  final int totalElements;
  final bool last;
}
