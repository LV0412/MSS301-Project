import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_session.dart';

class AuthSessionStorage {
  AuthSessionStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _lastHomeTabKey = 'navigation.lastHomeTab';

  final FlutterSecureStorage _secureStorage;

  Future<AuthSession?> read() async {
    final accessToken = await readAccessToken();
    final refreshToken = await readRefreshToken();

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthSession(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<String?> readAccessToken() {
    return _readValue(_accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _readValue(_refreshTokenKey);
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

  Future<String?> readLastHomeTab() {
    return _readValue(_lastHomeTabKey);
  }

  Future<void> saveLastHomeTab(String tabName) {
    return _secureStorage.write(key: _lastHomeTabKey, value: tabName);
  }

  Future<String?> _readValue(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (_) {
      return null;
    }
  }
}
