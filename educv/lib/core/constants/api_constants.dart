import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    // Force localhost for development to avoid CORS issues
    const url = 'http://localhost:8000/api/v1';
    if (kDebugMode) {
      debugPrint('API Base URL: $url');
    }
    return url;
  }

  // Auth
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String profile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';
  static const String requestDeletion = '/auth/request-deletion/';

  // CV
  static const String cvProfile = '/cv/profile/';
  static const String cvEducation = '/cv/education/';
  static const String cvExperience = '/cv/experience/';
  static const String cvSkills = '/cv/skills/';
  static const String cvLanguages = '/cv/languages/';
  static const String cvProjects = '/cv/projects/';
  static const String cvCertifications = '/cv/certifications/';
  static const String cvCompletion = '/cv/completion/';
  static const String cvGenerate = '/cv/generate/';
  static const String cvHistory = '/cv/history/';

  // Admin
  static const String adminStats = '/administration/stats/overview/';
  static const String adminStudents = '/administration/students/';
  static const String adminAuditLogs = '/administration/audit-logs/';
  static const String adminHealth = '/administration/health/';
}
