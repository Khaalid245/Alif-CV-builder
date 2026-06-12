import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../errors/error_handler.dart';
import '../errors/app_exception.dart';
import 'enterprise_toast.dart';

class EnterpriseApiErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error, {
    bool showToast = true,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final appException = ErrorHandler.handleError(error);
    final userMessage = _getUserFriendlyMessage(appException, customMessage);

    if (showToast) {
      _showErrorToast(context, userMessage, appException, onRetry);
    }
  }

  static String _getUserFriendlyMessage(
      AppException exception, String? customMessage) {
    if (customMessage != null) return customMessage;

    // Return user-friendly messages based on exception type
    switch (exception.code) {
      case 'TIMEOUT':
        return 'Connection timeout. Please check your internet and try again.';
      case 'NO_CONNECTION':
        return 'No internet connection. Please check your network.';
      case 'UNAUTHORIZED':
        return 'Your session has expired. Please log in again.';
      case 'FORBIDDEN':
        return 'You don\'t have permission to perform this action.';
      case 'NOT_FOUND':
        return 'The requested resource was not found.';
      case 'VALIDATION_ERROR':
        return _extractValidationMessage(exception);
      case 'RATE_LIMITED':
        return 'Too many requests. Please wait a moment and try again.';
      case 'INTERNAL_SERVER_ERROR':
        return 'Server error. Our team has been notified.';
      case 'SERVICE_UNAVAILABLE':
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return exception.message.isNotEmpty
            ? exception.message
            : 'Something went wrong. Please try again.';
    }
  }

  static String _extractValidationMessage(AppException exception) {
    // Try to extract specific validation errors from details
    if (exception.details is Map<String, dynamic>) {
      final details = exception.details as Map<String, dynamic>;

      // Check for field-specific errors
      if (details.containsKey('errors')) {
        final errors = details['errors'];
        if (errors is Map<String, dynamic>) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          if (firstError is String) {
            return firstError;
          }
        }
      }

      // Check for direct error message
      if (details.containsKey('message')) {
        return details['message'].toString();
      }
    }

    return exception.message.isNotEmpty
        ? exception.message
        : 'Please check your input and try again.';
  }

  static void _showErrorToast(
    BuildContext context,
    String message,
    AppException exception,
    VoidCallback? onRetry,
  ) {
    // Determine if we should show retry action
    final shouldShowRetry = _shouldShowRetry(exception) && onRetry != null;

    EnterpriseToast.error(
      context,
      message,
      duration: const Duration(seconds: 6),
      actionLabel: shouldShowRetry ? 'Retry' : null,
      onAction: shouldShowRetry ? onRetry : null,
    );
  }

  static bool _shouldShowRetry(AppException exception) {
    // Show retry for network errors and server errors, but not for validation errors
    switch (exception.code) {
      case 'TIMEOUT':
      case 'NO_CONNECTION':
      case 'INTERNAL_SERVER_ERROR':
      case 'SERVICE_UNAVAILABLE':
        return true;
      case 'UNAUTHORIZED':
      case 'FORBIDDEN':
      case 'NOT_FOUND':
      case 'VALIDATION_ERROR':
      case 'RATE_LIMITED':
        return false;
      default:
        return exception is NetworkException || exception is ServerException;
    }
  }

  // Success handler for consistent success messaging
  static void handleSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    EnterpriseToast.success(
      context,
      message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  // Loading handler for async operations
  static void showLoading(BuildContext context, String message) {
    EnterpriseToast.loading(context, message);
  }

  static void hideLoading() {
    EnterpriseToast.hide();
  }

  // Validation error handler for form submissions
  static void handleValidationErrors(
    BuildContext context,
    Map<String, dynamic> errors, {
    String? generalMessage,
  }) {
    final message =
        generalMessage ?? 'Please fix the errors below and try again.';

    // Extract first validation error for toast
    String? firstError;
    if (errors.isNotEmpty) {
      final firstField = errors.values.first;
      if (firstField is List && firstField.isNotEmpty) {
        firstError = firstField.first.toString();
      } else if (firstField is String) {
        firstError = firstField;
      }
    }

    EnterpriseToast.warning(
      context,
      firstError ?? message,
      duration: const Duration(seconds: 4),
    );
  }
}

// Extension for easy error handling in widgets
extension ErrorHandlingExtension on BuildContext {
  void handleApiError(
    dynamic error, {
    bool showToast = true,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    EnterpriseApiErrorHandler.handleError(
      this,
      error,
      showToast: showToast,
      customMessage: customMessage,
      onRetry: onRetry,
    );
  }

  void showApiSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    EnterpriseApiErrorHandler.handleSuccess(
      this,
      message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showApiLoading(String message) {
    EnterpriseApiErrorHandler.showLoading(this, message);
  }

  void hideApiLoading() {
    EnterpriseApiErrorHandler.hideLoading();
  }

  void handleValidationErrors(
    Map<String, dynamic> errors, {
    String? generalMessage,
  }) {
    EnterpriseApiErrorHandler.handleValidationErrors(
      this,
      errors,
      generalMessage: generalMessage,
    );
  }
}

// Async operation wrapper with automatic error handling
class EnterpriseAsyncOperation {
  static Future<T?> execute<T>(
    BuildContext context, {
    required Future<T> Function() operation,
    required String loadingMessage,
    String? successMessage,
    String? errorMessage,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    bool showLoadingToast = true,
    bool showSuccessToast = true,
    bool showErrorToast = true,
  }) async {
    try {
      if (showLoadingToast) {
        context.showApiLoading(loadingMessage);
      }

      final result = await operation();

      if (showLoadingToast) {
        context.hideApiLoading();
      }

      if (successMessage != null && showSuccessToast) {
        context.showApiSuccess(successMessage);
      }

      onSuccess?.call();
      return result;
    } catch (error) {
      if (showLoadingToast) {
        context.hideApiLoading();
      }

      if (showErrorToast) {
        context.handleApiError(
          error,
          customMessage: errorMessage,
          onRetry: () => execute(
            context,
            operation: operation,
            loadingMessage: loadingMessage,
            successMessage: successMessage,
            errorMessage: errorMessage,
            onSuccess: onSuccess,
            onError: onError,
            showLoadingToast: showLoadingToast,
            showSuccessToast: showSuccessToast,
            showErrorToast: showErrorToast,
          ),
        );
      }

      onError?.call();
      return null;
    }
  }
}
