class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException extends AppException {
  const ValidationException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);

  @override
  String toString() => 'ValidationException: $message';
}