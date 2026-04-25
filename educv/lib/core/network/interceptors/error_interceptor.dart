import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An unexpected error occurred';

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Certificate verification failed';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'An unexpected error occurred';
        break;
    }

    if (kDebugMode) {
      debugPrint('API Error: $errorMessage');
      debugPrint('Request: ${err.requestOptions.method} ${err.requestOptions.path}');
      debugPrint('Response: ${err.response?.data}');
    }

    // Create a new DioException with user-friendly message
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
    );

    handler.next(newError);
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred (Status: $statusCode)';
    }
  }
}