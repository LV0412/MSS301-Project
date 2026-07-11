import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

  static String get authApiBaseUrl =>
      dotenv.env['AUTH_API_BASE_URL'] ?? apiBaseUrl;

  static String get googleClientId =>
      dotenv.env['GOOGLE_CLIENT_ID'] ??
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
      '';

  static String get googleWebClientId => googleClientId;

  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? googleClientId;
}
