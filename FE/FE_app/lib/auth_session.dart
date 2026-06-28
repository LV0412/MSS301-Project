import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_api_client.dart';

const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

enum RestoreResult { authenticated, needsEmailVerification, unauthenticated }

class AuthSession extends ChangeNotifier {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  final AuthApiClient _api = AuthApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Account? account;
  String? accessToken;
  String? refreshToken;

  bool get isAuthenticated => accessToken != null && account != null;
  bool get needsEmailVerification =>
      account != null &&
      (!account!.emailVerified || account!.status == 'INACTIVE');

  Future<RestoreResult> restore() async {
    accessToken = await _storage.read(key: 'accessToken');
    refreshToken = await _storage.read(key: 'refreshToken');

    if (accessToken != null) {
      try {
        account = await _api.me(accessToken!);
        notifyListeners();
        return needsEmailVerification
            ? RestoreResult.needsEmailVerification
            : RestoreResult.authenticated;
      } catch (_) {
        // Continue to refresh token path.
      }
    }

    if (refreshToken != null) {
      try {
        final tokens = await _api.refresh(refreshToken!);
        await _storeTokens(tokens);
        return needsEmailVerification
            ? RestoreResult.needsEmailVerification
            : RestoreResult.authenticated;
      } catch (_) {
        await clear();
      }
    }

    return RestoreResult.unauthenticated;
  }

  Future<RestoreResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final tokens = await _api.register(
      email: email,
      password: password,
      fullName: fullName,
    );
    await _storeTokens(tokens);
    return needsEmailVerification
        ? RestoreResult.needsEmailVerification
        : RestoreResult.authenticated;
  }

  Future<RestoreResult> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _api.login(email: email, password: password);
    await _storeTokens(tokens);
    return needsEmailVerification
        ? RestoreResult.needsEmailVerification
        : RestoreResult.authenticated;
  }

  Future<RestoreResult> googleLogin() async {
    final signIn = GoogleSignIn.instance;
    await signIn.initialize(
      clientId: googleClientId.isEmpty ? null : googleClientId,
      serverClientId: googleServerClientId.isEmpty
          ? null
          : googleServerClientId,
    );

    if (!signIn.supportsAuthenticate()) {
      throw AuthApiException(
        'Google Sign-In is not available on this platform',
        0,
      );
    }

    final googleAccount = await signIn.authenticate();
    final idToken = googleAccount.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw AuthApiException('Google did not return an ID token', 0);
    }

    final tokens = await _api.googleLogin(idToken);
    await _storeTokens(tokens);
    return RestoreResult.authenticated;
  }

  Future<Account> verifyEmail(String otpCode) async {
    final email = account?.email;
    if (email == null) {
      throw AuthApiException('No account is waiting for verification', 0);
    }

    final verifiedAccount = await _api.verifyEmail(
      email: email,
      otpCode: otpCode,
    );
    account = verifiedAccount;
    notifyListeners();
    return verifiedAccount;
  }

  Future<void> resendOtp() async {
    final email = account?.email;
    if (email == null) {
      throw AuthApiException('No account is waiting for verification', 0);
    }
    await _api.resendOtp(email);
  }

  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) {
    return _api.resetPassword(resetToken: resetToken, newPassword: newPassword);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = accessToken;
    if (token == null) {
      throw AuthApiException('You are not logged in', 0);
    }
    await _api.changePassword(
      accessToken: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    final token = refreshToken;
    if (token != null) {
      try {
        await _api.logout(token);
      } catch (_) {
        // Local logout should still complete if the server is unreachable.
      }
    }
    await clear();
  }

  Future<void> clear() async {
    account = null;
    accessToken = null;
    refreshToken = null;
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    notifyListeners();
  }

  Future<void> _storeTokens(AuthTokens tokens) async {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
    account = tokens.account;
    await _storage.write(key: 'accessToken', value: tokens.accessToken);
    await _storage.write(key: 'refreshToken', value: tokens.refreshToken);
    notifyListeners();
  }
}
