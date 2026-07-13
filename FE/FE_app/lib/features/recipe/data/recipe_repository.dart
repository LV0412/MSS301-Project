import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_api_client.dart';
import 'models/recipe.dart';

class RecipeRepository {
  RecipeRepository({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;

  Future<List<Recipe>> getRecipes({int page = 0, int size = 20}) async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>(
        '/recipes',
        queryParameters: {'page': page, 'size': size},
      ),
    );

    final content = response.data?['content'];
    if (content is! List) return const [];

    return content
        .whereType<Map>()
        .map(
          (item) => Recipe.fromJson(
            item.map((key, value) => MapEntry('$key', value)),
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllergens({int size = 100}) async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>(
        '/allergens',
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
}
