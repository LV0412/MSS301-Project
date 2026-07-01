import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.code, this.statusCode});

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        message: data['message']?.toString() ?? 'Request failed.',
        code: data['code']?.toString(),
        statusCode: error.response?.statusCode,
      );
    }

    return ApiException(
      message: error.message ?? 'Cannot connect to server.',
      statusCode: error.response?.statusCode,
    );
  }

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() {
    if (code == null) return message;
    return '$code: $message';
  }
}
