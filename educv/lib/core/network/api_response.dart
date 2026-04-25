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