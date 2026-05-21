import 'package:dio/dio.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }

  factory ApiResponse.fromResponse(Response response, T Function(dynamic)? fromJsonT) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data, fromJsonT);
    }
    
    // Handle direct data responses
    return ApiResponse<T>(
      success: response.statusCode == 200,
      message: response.statusMessage ?? 'Success',
      data: fromJsonT != null ? fromJsonT(data) : data,
    );
  }
}

class ApiError {
  final String message;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? '',
      details: json['details'],
    );
  }
}

// Extension to add success/error properties to Dio Response
extension ResponseExtension on Response {
  bool get success => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  
  ApiError? get error {
    if (!success) {
      if (data is Map<String, dynamic>) {
        final errorData = data['error'];
        if (errorData is Map<String, dynamic>) {
          return ApiError.fromJson(errorData);
        }
        // If no nested error object, create one from the response message
        return ApiError(
          message: data['message'] ?? statusMessage ?? 'Unknown error',
          details: data,
        );
      }
      return ApiError(
        message: statusMessage ?? 'Unknown error',
      );
    }
    return null;
  }
  
  String get message {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? statusMessage ?? '';
    }
    return statusMessage ?? '';
  }
  
  dynamic get responseData {
    if (data is Map<String, dynamic>) {
      return data['data'];
    }
    return data;
  }
}
