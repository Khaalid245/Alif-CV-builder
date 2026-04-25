import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'app_exception.dart';

class ErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppException) {
      return error;
    } else {
      if (kDebugMode) {
        debugPrint('Unexpected error: $error');
      }
      return AppException(
        message: 'An unexpected error occurred',
        details: error.toString(),
      );
    }
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleStatusCodeError(error);

      case DioExceptionType.cancel:
        return const AppException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
          code: 'NO_CONNECTION',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Certificate verification failed',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        return AppException(
          message: 'An unexpected error occurred',
          code: 'UNKNOWN',
          details: error.message,
        );
    }
  }

  static AppException _handleStatusCodeError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to extract message from response
    String message = 'An error occurred';
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message.isNotEmpty ? message : 'Bad request. Please check your input.',
          code: 'BAD_REQUEST',
          details: responseData,
        );

      case 401:
        return AuthException(
          message: message.isNotEmpty ? message : 'Authentication failed. Please login again.',
          code: 'UNAUTHORIZED',
          details: responseData,
        );

      case 403:
        return AuthException(
          message: message.isNotEmpty ? message : 'Access denied. You don\'t have permission.',
          code: 'FORBIDDEN',
          details: responseData,
        );

      case 404:
        return AppException(
          message: message.isNotEmpty ? message : 'Resource not found.',
          code: 'NOT_FOUND',
          details: responseData,
        );

      case 422:
        return ValidationException(
          message: message.isNotEmpty ? message : 'Validation failed. Please check your input.',
          code: 'VALIDATION_ERROR',
          details: responseData,
        );

      case 429:
        return AppException(
          message: message.isNotEmpty ? message : 'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
          details: responseData,
        );

      case 500:
        return ServerException(
          message: message.isNotEmpty ? message : 'Server error. Please try again later.',
          code: 'INTERNAL_SERVER_ERROR',
          details: responseData,
        );

      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message.isNotEmpty ? message : 'Service temporarily unavailable. Please try again later.',
          code: 'SERVICE_UNAVAILABLE',
          details: responseData,
        );

      default:
        return ServerException(
          message: message.isNotEmpty ? message : 'An unexpected server error occurred',
          code: 'SERVER_ERROR_$statusCode',
          details: responseData,
        );
    }
  }
}