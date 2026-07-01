import 'account.dart';
import 'auth_session.dart';

class AuthResult {
  const AuthResult({required this.session, required this.account});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      session: AuthSession(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      ),
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
    );
  }

  final AuthSession session;
  final Account account;
}
