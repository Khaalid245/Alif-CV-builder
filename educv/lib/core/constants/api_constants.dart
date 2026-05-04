import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';
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

  // Admin — all paths match Django /administration/ mount
  static const String adminStatsOverview = '/administration/stats/overview/';
  static const String adminStatsTemplates = '/administration/stats/templates/';
  static const String adminStatsGrowth = '/administration/stats/growth/';
  static const String adminStudents = '/administration/students/';
  static const String adminDeletionRequests =
      '/administration/students/deletion-requests/';
  static const String adminGeneratedCVs = '/administration/cvs/generated/';
  static const String adminCVSectionFillRates =
      '/administration/cvs/stats/popular-sections/';
  static const String adminAuditLogs = '/administration/audit-logs/';
  static const String adminAuditLogsSecurity =
      '/administration/audit-logs/security/';
  static const String adminHealth = '/administration/health/';
  static const String adminHealthDetailed = '/administration/health/detailed/';
}
