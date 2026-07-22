import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_api_client.dart';
import 'models/nutrition_goal.dart';
import 'models/user_profile.dart';

class UserRepository {
  UserRepository({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;

  Future<UserProfile> getCurrentUser() async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>('/users/me'),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'User service không trả dữ liệu hồ sơ.',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateCurrentUser({
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
        '/users/me',
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

  Future<Map<String, dynamic>?> getHealthProfile() {
    return _getOptionalMap('/users/me/health-profile');
  }

  Future<Map<String, dynamic>> saveHealthProfile({
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
          '/users/me/health-profile',
          data: data,
        ),
      );
      return response.data ?? const {};
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      final response = await _request(
        () => _apiClient.dio.post<Map<String, dynamic>>(
          '/users/me/health-profile',
          data: data,
        ),
      );
      return response.data ?? const {};
    }
  }

  Future<NutritionGoal> getNutritionGoal() async {
    final response = await _request(
      () =>
          _apiClient.dio.get<Map<String, dynamic>>('/users/me/nutrition-goal'),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'User Service không trả dữ liệu mục tiêu dinh dưỡng.',
      );
    }
    return NutritionGoal.fromJson(data);
  }

  Future<NutritionGoal> saveNutritionGoal({
    required String goalType,
    double? targetWeight,
    int? durationWeeks,
    double? dailyCaloriesGoal,
  }) async {
    final data = <String, dynamic>{
      'goalType': goalType,
      'targetWeight': targetWeight,
      'durationWeeks': durationWeeks,
      'dailyCaloriesGoal': dailyCaloriesGoal,
    };

    final response = await _request(
      () => _apiClient.dio.put<Map<String, dynamic>>(
        '/users/me/nutrition-goal',
        data: data,
      ),
    );
    final responseData = response.data;
    if (responseData == null) {
      throw const ApiException(
        message: 'User Service không trả dữ liệu mục tiêu đã lưu.',
      );
    }
    return NutritionGoal.fromJson(responseData);
  }

  Future<NutritionGoalPreview> previewNutritionGoal({
    required String goalType,
    double? targetWeight,
    int? durationWeeks,
    double? dailyCaloriesGoal,
    CancelToken? cancelToken,
  }) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/users/me/nutrition-goal/preview',
        data: <String, dynamic>{
          'goalType': goalType,
          'targetWeight': targetWeight,
          'durationWeeks': durationWeeks,
          'dailyCaloriesGoal': dailyCaloriesGoal,
        },
        cancelToken: cancelToken,
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'User Service không trả dữ liệu xem trước mục tiêu.',
      );
    }
    return NutritionGoalPreview.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> getDietPreferences() {
    return _getOptionalList('/users/me/diet-preferences');
  }

  Future<List<Map<String, dynamic>>> getAllergies() {
    return _getOptionalList('/users/me/allergies');
  }

  Future<List<Map<String, dynamic>>> getFavorites() {
    return _getOptionalList('/users/me/favorites');
  }

  Future<Map<String, dynamic>> addFavorite({required int recipeId}) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/users/me/favorites',
        data: {'recipeId': recipeId},
      ),
    );
    return response.data ?? const {};
  }

  Future<void> deleteFavorite({required int favoriteId}) async {
    await _request(
      () => _apiClient.dio.delete<void>('/users/me/favorites/$favoriteId'),
    );
  }

  Future<List<Map<String, dynamic>>> getFoodLogs({
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
        '/users/me/food-logs',
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
    required int recipeId,
    required double quantity,
    required String mealType,
    required String logDate,
  }) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/users/me/food-logs',
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
    required int logId,
    required int recipeId,
    required double quantity,
    required String mealType,
    required String logDate,
  }) async {
    final response = await _request(
      () => _apiClient.dio.put<Map<String, dynamic>>(
        '/users/me/food-logs/$logId',
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

  Future<void> deleteFoodLog({required int logId}) async {
    await _request(
      () => _apiClient.dio.delete<void>('/users/me/food-logs/$logId'),
    );
  }

  Future<void> syncDietPreferences({required Set<String> dietTypes}) async {
    final current = await getDietPreferences();
    final desired = dietTypes.map((item) => item.trim().toUpperCase()).toSet();

    for (final preference in current) {
      final id = (preference['preferenceId'] as num?)?.toInt();
      final dietType = preference['dietType']?.toString().toUpperCase();
      if (id != null && !desired.contains(dietType)) {
        await _request(
          () => _apiClient.dio.delete<void>('/users/me/diet-preferences/$id'),
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
          '/users/me/diet-preferences',
          data: {'dietType': dietType},
        ),
      );
    }
  }

  Future<void> syncAllergies({required Map<int, String> allergies}) async {
    final current = await getAllergies();
    final currentByAllergen = <int, Map<String, dynamic>>{};
    for (final allergy in current) {
      final allergenId = (allergy['allergenId'] as num?)?.toInt();
      if (allergenId != null) currentByAllergen[allergenId] = allergy;
    }

    for (final entry in currentByAllergen.entries) {
      final allergyId = (entry.value['allergyId'] as num?)?.toInt();
      if (allergyId != null && !allergies.containsKey(entry.key)) {
        await _request(
          () => _apiClient.dio.delete<void>('/users/me/allergies/$allergyId'),
        );
      }
    }

    for (final entry in allergies.entries) {
      final severity = entry.value.toUpperCase();
      final existing = currentByAllergen[entry.key];
      if (existing == null) {
        await _request(
          () => _apiClient.dio.post<Map<String, dynamic>>(
            '/users/me/allergies',
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
            '/users/me/allergies/$allergyId',
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
      if (CancelToken.isCancel(error)) rethrow;
      throw ApiException.fromDio(error);
    }
  }
}
