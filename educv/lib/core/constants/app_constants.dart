import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // App Info
  static String get appName => dotenv.env['APP_NAME'] ?? 'EduCV';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Pagination
  static const int defaultPageSize = 20;

  // PDF Templates
  static const List<String> pdfTemplates = [
    'classic',
    'modern',
    'academic',
  ];

  // File Limits
  static const int maxProfilePhotoSize = 5 * 1024 * 1024; // 5MB

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 600;
}