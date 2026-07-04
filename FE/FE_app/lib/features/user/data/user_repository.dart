import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_api_client.dart';
import '../../auth/data/models/account.dart';
import 'models/user_profile.dart';

class UserRepository {
  UserRepository({AuthApiClient? apiClient})
    : _apiClient = apiClient ?? AuthApiClient();

  final AuthApiClient _apiClient;

  Future<List<UserProfile>> getUsers({int page = 0, int size = 20}) async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>(
        '/users',
        queryParameters: {'page': page, 'size': size},
      ),
    );
    final content = response.data?['content'];
    if (content is! List) return const [];

    return content
        .whereType<Map<String, dynamic>>()
        .map(UserProfile.fromJson)
        .toList();
  }

  Future<UserProfile?> findByEmail(String email) async {
    final users = await getUsers(size: 100);
    for (final user in users) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  Future<UserProfile> createFromAccount(Account account) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/users',
        data: {
          'email': account.email,
          'passwordHash': 'managed-by-auth-service',
          'fullName': account.fullName,
          'gender': 'OTHER',
        },
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(
        message: 'User service không trả dữ liệu hồ sơ.',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<Map<String, dynamic>?> getHealthProfile(int userId) {
    return _getOptionalMap('/users/$userId/health-profile');
  }

  Future<Map<String, dynamic>?> getNutritionGoal(int userId) {
    return _getOptionalMap('/users/$userId/nutrition-goal');
  }

  Future<List<Map<String, dynamic>>> getDietPreferences(int userId) {
    return _getOptionalList('/users/$userId/diet-preferences');
  }

  Future<List<Map<String, dynamic>>> getAllergies(int userId) {
    return _getOptionalList('/users/$userId/allergies');
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
