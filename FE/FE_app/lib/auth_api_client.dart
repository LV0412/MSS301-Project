import 'dart:convert';

import 'package:http/http.dart' as http;

const authApiBaseUrl = String.fromEnvironment(
  'AUTH_API_BASE_URL',
  defaultValue: 'http://localhost:8000/api/v1',
);

class AuthApiException implements Exception {
  AuthApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}

class Account {
  const Account({
    required this.accountId,
    required this.email,
    required this.provider,
    required this.role,
    required this.status,
    required this.emailVerified,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'] as int,
      email: json['email'] as String,
      provider: json['provider'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      emailVerified: json['emailVerified'] as bool,
    );
  }

  final int accountId;
  final String email;
  final String provider;
  final String role;
  final String status;
  final bool emailVerified;
}

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
    required this.account,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
  final Account account;
}

class AuthApiClient {
  AuthApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthTokens> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final json = await _post('/auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
      'deviceInfo': 'Flutter App',
    });
    return AuthTokens.fromJson(json);
  }

  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
      'deviceInfo': 'Flutter App',
    });
    return AuthTokens.fromJson(json);
  }

  Future<AuthTokens> googleLogin(String idToken) async {
    final json = await _post('/auth/google', {
      'idToken': idToken,
      'deviceInfo': 'Flutter App',
    });
    return AuthTokens.fromJson(json);
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final json = await _post('/auth/refresh', {
      'refreshToken': refreshToken,
      'deviceInfo': 'Flutter App',
    });
    return AuthTokens.fromJson(json);
  }

  Future<void> logout(String refreshToken) async {
    await _post('/auth/logout', {'refreshToken': refreshToken});
  }

  Future<Account> me(String accessToken) async {
    final response = await _client.get(
      _uri('/auth/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return Account.fromJson(_decode(response));
  }

  Future<Account> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    final json = await _post('/auth/verify-email', {
      'email': email,
      'otpCode': otpCode,
    });
    return Account.fromJson(json);
  }

  Future<void> resendOtp(String email) async {
    await _post('/auth/resend-otp', {'email': email});
  }

  Future<void> forgotPassword(String email) async {
    await _post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await _post('/auth/reset-password', {
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
  }

  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.post(
      _uri('/auth/change-password'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw AuthApiException(
      body['message'] as String? ?? 'Request failed',
      response.statusCode,
    );
  }

  Uri _uri(String path) => Uri.parse('$authApiBaseUrl$path');
}
