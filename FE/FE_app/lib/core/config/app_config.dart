class AppConfig {
  const AppConfig._();

  static const authApiBaseUrl = String.fromEnvironment(
    'AUTH_API_BASE_URL',
    defaultValue: 'http://localhost:8002/api/v1',
  );
}
