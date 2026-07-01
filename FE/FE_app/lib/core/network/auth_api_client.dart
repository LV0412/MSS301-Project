import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/auth_session_storage.dart';
import 'api_exception.dart';
import '../../features/auth/data/models/auth_session.dart';

class AuthApiClient {
  AuthApiClient({AuthSessionStorage? sessionStorage})
    : _sessionStorage = sessionStorage ?? AuthSessionStorage() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _attachAccessToken,
        onError: _refreshAndRetry,
      ),
    );
  }

  final AuthSessionStorage _sessionStorage;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.authApiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Dio get dio => _dio;

  Future<Response<dynamic>> request(Future<Response<dynamic>> Function() call) {
    return call().onError<DioException>((error, stackTrace) {
      throw ApiException.fromDio(error);
    });
  }

  Future<void> _attachAccessToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _refreshAndRetry(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;
    final path = error.requestOptions.path;
    final canRefresh = statusCode == 401 && !path.contains('/auth/refresh');

    if (!canRefresh) {
      handler.next(error);
      return;
    }

    final refreshToken = await _sessionStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      handler.next(error);
      return;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.authApiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = refreshResponse.data;
      if (data == null) {
        handler.next(error);
        return;
      }

      await _sessionStorage.save(
        AuthSession(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        ),
      );

      final accessToken = data['accessToken'] as String;
      final retryOptions = error.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $accessToken';
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await _sessionStorage.clear();
      handler.next(error);
    }
  }
}
