import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_api_client.dart';
import 'models/user_profile.dart';

class UserRepository {
  UserRepository({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;

  Future<UserProfile> getUserById(int userId) async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>('/users/$userId'),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'User service không trả dữ liệu hồ sơ.',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateUser({
    required int userId,
    required String fullName,
    String? dob,
    required String gender,
  }) async {
    final requestData = <String, dynamic>{
      'fullName': fullName,
      'gender': gender,
    };
    if (dob != null) requestData['dob'] = dob;

    final response = await _request(
      () => _apiClient.dio.put<Map<String, dynamic>>(
        '/users/$userId',
        data: requestData,
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'User service không trả dữ liệu hồ sơ đã cập nhật.',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<Map<String, dynamic>?> getHealthProfile(int userId) {
    return _getOptionalMap('/users/$userId/health-profile');
  }

  Future<Map<String, dynamic>> saveHealthProfile({
    required int userId,
    required double height,
    required double weight,
    required String activityLevel,
  }) async {
    final data = {
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
    };

    try {
      final response = await _request(
        () => _apiClient.dio.put<Map<String, dynamic>>(
          '/users/$userId/health-profile',
          data: data,
        ),
      );
      return response.data ?? const {};
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      final response = await _request(
        () => _apiClient.dio.post<Map<String, dynamic>>(
          '/users/$userId/health-profile',
          data: data,
        ),
      );
      return response.data ?? const {};
    }
  }

  Future<Map<String, dynamic>?> getNutritionGoal(int userId) {
    return _getOptionalMap('/users/$userId/nutrition-goal');
  }

  Future<Map<String, dynamic>> saveNutritionGoal({
    required int userId,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final data = {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };

    try {
      final response = await _request(
        () => _apiClient.dio.put<Map<String, dynamic>>(
          '/users/$userId/nutrition-goal',
          data: data,
        ),
      );
      return response.data ?? const {};
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      final response = await _request(
        () => _apiClient.dio.post<Map<String, dynamic>>(
          '/users/$userId/nutrition-goal',
          data: data,
        ),
      );
      return response.data ?? const {};
    }
  }

  Future<List<Map<String, dynamic>>> getDietPreferences(int userId) {
    return _getOptionalList('/users/$userId/diet-preferences');
  }

  Future<List<Map<String, dynamic>>> getAllergies(int userId) {
    return _getOptionalList('/users/$userId/allergies');
  }

  Future<List<Map<String, dynamic>>> getFavorites(int userId) {
    return _getOptionalList('/users/$userId/favorites');
  }

  Future<Map<String, dynamic>> addFavorite({
    required int userId,
    required int recipeId,
  }) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/users/$userId/favorites',
        data: {'recipeId': recipeId},
      ),
    );
    return response.data ?? const {};
  }

  Future<void> deleteFavorite({
    required int userId,
    required int favoriteId,
  }) async {
    await _request(
      () => _apiClient.dio.delete<void>('/users/$userId/favorites/$favoriteId'),
    );
  }

  Future<List<Map<String, dynamic>>> getFoodLogs({
    required int userId,
    String? date,
    String? mealType,
    int page = 0,
    int size = 100,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'logDate,desc',
    };
    if (date != null) queryParameters['date'] = date;
    if (mealType != null) queryParameters['mealType'] = mealType;

    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>(
        '/users/$userId/food-logs',
        queryParameters: queryParameters,
      ),
    );
    final content = response.data?['content'];
    if (content is! List) return const [];
    return content
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();
  }

  Future<Map<String, dynamic>> createFoodLog({
    required int userId,
    required int recipeId,
    required double quantity,
    required String mealType,
    required String logDate,
  }) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/users/$userId/food-logs',
        data: {
          'recipeId': recipeId,
          'quantity': quantity,
          'mealType': mealType,
          'logDate': logDate,
        },
      ),
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> updateFoodLog({
    required int userId,
    required int logId,
    required int recipeId,
    required double quantity,
    required String mealType,
    required String logDate,
  }) async {
    final response = await _request(
      () => _apiClient.dio.put<Map<String, dynamic>>(
        '/users/$userId/food-logs/$logId',
        data: {
          'recipeId': recipeId,
          'quantity': quantity,
          'mealType': mealType,
          'logDate': logDate,
        },
      ),
    );
    return response.data ?? const {};
  }

  Future<void> deleteFoodLog({required int userId, required int logId}) async {
    await _request(
      () => _apiClient.dio.delete<void>('/users/$userId/food-logs/$logId'),
    );
  }

  Future<void> syncDietPreferences({
    required int userId,
    required Set<String> dietTypes,
  }) async {
    final current = await getDietPreferences(userId);
    final desired = dietTypes.map((item) => item.trim().toUpperCase()).toSet();

    for (final preference in current) {
      final id = (preference['preferenceId'] as num?)?.toInt();
      final dietType = preference['dietType']?.toString().toUpperCase();
      if (id != null && !desired.contains(dietType)) {
        await _request(
          () => _apiClient.dio.delete<void>(
            '/users/$userId/diet-preferences/$id',
          ),
        );
      }
    }

    final existingTypes = current
        .map((item) => item['dietType']?.toString().toUpperCase())
        .whereType<String>()
        .toSet();
    for (final dietType in desired.difference(existingTypes)) {
      await _request(
        () => _apiClient.dio.post<Map<String, dynamic>>(
          '/users/$userId/diet-preferences',
          data: {'dietType': dietType},
        ),
      );
    }
  }

  Future<void> syncAllergies({
    required int userId,
    required Map<int, String> allergies,
  }) async {
    final current = await getAllergies(userId);
    final currentByAllergen = <int, Map<String, dynamic>>{};
    for (final allergy in current) {
      final allergenId = (allergy['allergenId'] as num?)?.toInt();
      if (allergenId != null) currentByAllergen[allergenId] = allergy;
    }

    for (final entry in currentByAllergen.entries) {
      final allergyId = (entry.value['allergyId'] as num?)?.toInt();
      if (allergyId != null && !allergies.containsKey(entry.key)) {
        await _request(
          () => _apiClient.dio.delete<void>(
            '/users/$userId/allergies/$allergyId',
          ),
        );
      }
    }

    for (final entry in allergies.entries) {
      final severity = entry.value.toUpperCase();
      final existing = currentByAllergen[entry.key];
      if (existing == null) {
        await _request(
          () => _apiClient.dio.post<Map<String, dynamic>>(
            '/users/$userId/allergies',
            data: {'allergenId': entry.key, 'severity': severity},
          ),
        );
        continue;
      }

      final allergyId = (existing['allergyId'] as num?)?.toInt();
      final currentSeverity = existing['severity']?.toString().toUpperCase();
      if (allergyId != null && currentSeverity != severity) {
        await _request(
          () => _apiClient.dio.put<Map<String, dynamic>>(
            '/users/$userId/allergies/$allergyId',
            data: {'allergenId': entry.key, 'severity': severity},
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _getOptionalMap(String path) async {
    try {
      final response = await _request(
        () => _apiClient.dio.get<Map<String, dynamic>>(path),
      );
      return response.data;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _getOptionalList(String path) async {
    try {
      final response = await _request(() => _apiClient.dio.get<dynamic>(path));
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
      }
      return const [];
    } on ApiException catch (error) {
      if (error.statusCode == 404) return const [];
      rethrow;
    }
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
