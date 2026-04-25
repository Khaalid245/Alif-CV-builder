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

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}