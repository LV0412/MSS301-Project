import 'dart:convert';

import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.code, this.statusCode});

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    final json = _asJsonObject(data);
    if (json != null) {
      final code = json['code']?.toString();
      final message = json['message']?.toString();
      return ApiException(
        message: _localizedMessage(
          code: code,
          message: message,
          statusCode: error.response?.statusCode,
        ),
        code: code,
        statusCode: error.response?.statusCode,
      );
    }

    return ApiException(
      message: _fallbackMessage(error),
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

  static Map<String, dynamic>? _asJsonObject(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _localizedMessage({
    required String? code,
    required String? message,
    required int? statusCode,
  }) {
    return switch (code) {
      'EMAIL_NOT_VERIFIED' =>
        'Email chưa được xác thực. Vui lòng xác thực email trước khi đăng nhập.',
      'INVALID_CREDENTIALS' => 'Email hoặc mật khẩu không đúng.',
      'ACCOUNT_LOCKED' => 'Tài khoản đang bị khóa. Vui lòng thử lại sau.',
      'ACCOUNT_DISABLED' => 'Tài khoản chưa sẵn sàng để đăng nhập.',
      'EMAIL_ALREADY_EXISTS' => 'Email này đã được đăng ký.',
      'MALFORMED_REQUEST' => 'Dữ liệu gửi lên chưa đúng định dạng.',
      'ACCESS_DENIED' =>
        'Không thể thực hiện thao tác này. Vui lòng đăng xuất rồi thử lại hoặc dùng email khác.',
      'UNAUTHORIZED' => 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.',
      _ => message ?? _statusMessage(statusCode),
    };
  }

  static String _fallbackMessage(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) return _statusMessage(statusCode);

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => 'Kết nối API quá lâu. Vui lòng thử lại.',
      DioExceptionType.connectionError =>
        'Không thể kết nối API Gateway. Kiểm tra Docker service và mạng.',
      _ => 'Không thể xử lý yêu cầu. Vui lòng thử lại.',
    };
  }

  static String _statusMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Yêu cầu chưa hợp lệ. Vui lòng kiểm tra lại thông tin.',
      401 => 'Bạn cần đăng nhập để tiếp tục.',
      403 => 'Bạn chưa có quyền thực hiện thao tác này.',
      404 => 'Không tìm thấy dữ liệu yêu cầu.',
      409 => 'Dữ liệu đã tồn tại.',
      500 => 'Máy chủ đang gặp lỗi. Vui lòng thử lại sau.',
      _ => 'Không thể xử lý yêu cầu. Vui lòng thử lại.',
    };
  }
}
