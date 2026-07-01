class AuthSession {
  const AuthSession({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}
