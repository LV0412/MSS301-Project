import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_api_client.dart';
import '../../../core/storage/auth_session_storage.dart';
import 'models/account.dart';
import 'models/auth_result.dart';

class AuthRepository {
  factory AuthRepository({
    AuthApiClient? apiClient,
    AuthSessionStorage? sessionStorage,
  }) {
    final storage = sessionStorage ?? AuthSessionStorage();
    return AuthRepository._(
      apiClient ?? AuthApiClient(sessionStorage: storage),
      storage,
    );
  }

  AuthRepository._(this._apiClient, this._sessionStorage);

  final AuthApiClient _apiClient;
  final AuthSessionStorage _sessionStorage;

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _request(
      () => _apiClient.dio.post<dynamic>(
        '/auth/register',
        data: {'email': email, 'password': password, 'fullName': fullName},
      ),
    );
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Empty login response.');
    }

    final result = AuthResult.fromJson(data);
    await _sessionStorage.save(result.session);
    return result;
  }

  Future<AuthResult> googleLogin({required String idToken}) async {
    final response = await _request(
      () => _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'idToken': idToken},
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Empty Google login response.');
    }

    final result = AuthResult.fromJson(data);
    await _sessionStorage.save(result.session);
    return result;
  }

  Future<void> verifyEmail({required String email, required String otp}) async {
    await _request(
      () => _apiClient.dio.post<dynamic>(
        '/auth/verify-email',
        data: {'email': email, 'otp': otp},
      ),
    );
  }

  Future<void> resendVerification(String email) async {
    await _request(
      () => _apiClient.dio.post<dynamic>(
        '/auth/resend-otp',
        data: {'email': email},
      ),
    );
  }

  Future<Account> me() async {
    final response = await _request(
      () => _apiClient.dio.get<Map<String, dynamic>>('/auth/me'),
    );
    final data = response.data;
    if (data == null) {
      throw const ApiException(message: 'Empty account response.');
    }
    return Account.fromJson(data);
  }

  Future<void> forgotPassword(String email) async {
    await _request(
      () => _apiClient.dio.post<dynamic>(
        '/auth/forgot-password',
        data: {'email': email},
      ),
    );
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _request(
      () => _apiClient.dio.post<dynamic>(
        '/auth/reset-password',
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      ),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _request(
      () => _apiClient.dio.post<dynamic>(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      ),
    );
    await _sessionStorage.clear();
  }

  Future<void> logout() async {
    final refreshToken = await _sessionStorage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _request(
        () => _apiClient.dio.post<dynamic>(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        ),
      );
    }
    await _sessionStorage.clear();
  }

  Future<void> clearSession() {
    return _sessionStorage.clear();
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
