import 'package:dio/dio.dart';

class ApiError {
  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final bool isAuthError;

  ApiError({
    required this.message,
    this.statusCode,
    this.isNetworkError = false,
    this.isAuthError = false,
  });

  factory ApiError.fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiError(
        message: 'No internet connection. Check your network and try again.',
        isNetworkError: true,
      );
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return ApiError(
        message: 'Session expired. Please login again.',
        statusCode: 401,
        isAuthError: true,
      );
    }
    if (statusCode == 403) {
      return ApiError(
        message: 'You do not have permission to perform this action.',
        statusCode: 403,
      );
    }
    if (statusCode == 429) {
      return ApiError(
        message: 'Too many requests. Please wait a moment and try again.',
        statusCode: 429,
      );
    }
    if (statusCode == 422) {
      final errors = e.response?.data?['errors'];
      if (errors is Map) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return ApiError(message: firstError.first.toString());
        }
      }
      return ApiError(
        message: e.response?.data?['message'] ?? 'Validation failed.',
        statusCode: 422,
      );
    }

    return ApiError(
      message: e.response?.data?['message'] ?? 'Something went wrong. Please try again.',
      statusCode: statusCode,
    );
  }
}
