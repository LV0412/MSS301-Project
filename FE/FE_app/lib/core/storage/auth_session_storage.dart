import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_session.dart';

class AuthSessionStorage {
  AuthSessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';

  final FlutterSecureStorage _secureStorage;

  Future<AuthSession?> read() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthSession(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> save(AuthSession session) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: session.accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: session.refreshToken),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}
