import '../config/app_config.dart';

/// Refactored API Constants with configurable base URL and no hardcoded fallbacks.
/// All API endpoints are now properly configured through AppConfig.
class ApiConstants {
  /// Dynamic base URL from configuration - no hardcoded fallbacks
  static String get baseUrl => AppConfig.baseUrl;

  /// Helper to check if running in production
  static bool get isProductionEnvironment => AppConfig.environment == 'production';

  // ─── Authentication Endpoints ──────────────────────────────────────────────
  static const String register = '/auth/register/';
  static const String login = '/auth/login/';
  static const String logout = '/auth/logout/';
  static const String tokenRefresh = '/auth/token/refresh/';
  static const String profile = '/auth/profile/';
  static const String updateProfile = '/auth/profile/update/';
  static const String changePassword = '/auth/change-password/';
  static const String passwordReset = '/auth/password-reset/';
  static const String passwordResetConfirm = '/auth/password-reset/confirm/';
  static const String requestDeletion = '/auth/request-deletion/';
  static const String logoutAll = '/auth/logout-all/';

  // ─── CV Management Endpoints ───────────────────────────────────────────────
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
  static String cvDownload(String generatedCvId) => '/cv/download/$generatedCvId/';
  static const String announcement = '/cv/announcement/';

  // ─── CV Intelligence Endpoints ─────────────────────────────────────────────
  static const String cvAnalyze = '/cv/analyze/';
  static const String cvScore = '/cv/score/';
  static const String cvDashboard = '/cv/dashboard/';

  // ─── Workflow Control System Endpoints ────────────────────────────────────
  static const String workflowInstances = '/workflow/instances/';
  static const String workflowConfigurations = '/workflow/configurations/';
  static String workflowTransition(String instanceId) => '/workflow/instances/$instanceId/transition/';
  static String workflowCV(String cvId) => '/workflow/cv/$cvId/';
  static const String workflowDashboard = '/workflow/dashboard/';

  // ─── Administration Endpoints ──────────────────────────────────────────────
  static const String adminStatsOverview = '/administration/stats/overview/';
  static const String adminStatsTemplates = '/administration/stats/templates/';
  static const String adminStatsGrowth = '/administration/stats/growth/';
  static const String adminStudents = '/administration/students/';
  static const String adminDeletionRequests = '/administration/students/deletion-requests/';
  static const String adminGeneratedCVs = '/administration/cvs/generated/';
  static const String adminCVSectionFillRates = '/administration/cvs/stats/popular-sections/';
  static const String adminAuditLogs = '/administration/audit-logs/';
  static const String adminAuditLogsSecurity = '/administration/audit-logs/security/';
  static const String adminHealth = '/administration/health/';
  static const String adminHealthDetailed = '/administration/health/detailed/';

  // ─── Notification Endpoints ───────────────────────────────────────────────
  static const String notifications = '/notifications/';
  static const String notificationStats = '/notifications/stats/';
  static const String notificationPreferences = '/notifications/preferences/';
  static String markNotificationRead(String id) => '/notifications/$id/mark_read/';
  static const String markMultipleNotificationsRead = '/notifications/mark_multiple_read/';

  // ─── Analytics Endpoints ───────────────────────────────────────────────────
  static const String analyticsDashboard = '/analytics/dashboard/';
  static const String analyticsSnapshots = '/analytics/snapshots/';
  static const String createSnapshot = '/analytics/snapshots/create/';
  static const String trendAnalysis = '/analytics/trend-analysis/';
  static const String benchmarking = '/analytics/benchmarking/';
  static const String completionStatistics = '/analytics/completion-statistics/';

  // ─── Template Engine Endpoints ────────────────────────────────────────────
  static const String templateIndustries = '/templates/industries/';
  static const String templateRoles = '/templates/roles/';
  static const String templateCategories = '/templates/categories/';
  static const String templates = '/templates/templates/';
  static const String templateRecommendations = '/templates/templates/recommendations/';
  static const String templatePopular = '/templates/templates/popular/';
  static const String templatePreferences = '/templates/preferences/';
  static String templateDetail(String slug) => '/templates/templates/$slug/';
  static String templatePreview(String slug) => '/templates/templates/$slug/preview/';
  static String templateRender(String slug) => '/templates/templates/$slug/render/';
  static String templateFavorite(String slug) => '/templates/templates/$slug/favorite/';
  static String templateUnfavorite(String slug) => '/templates/templates/$slug/unfavorite/';

  // ─── Configuration Validation ──────────────────────────────────────────────
  /// Validates that all required configuration is properly set
  static void validateConfiguration() {
    try {
      final url = baseUrl;
      if (url.isEmpty) {
        throw Exception('API base URL is not configured');
      }
      
      if (isProductionEnvironment && url.contains('localhost')) {
        throw Exception('Production environment cannot use localhost URLs');
      }
      
      print('API Configuration validated successfully');
      print('Base URL: $url');
      print('Environment: ${AppConfig.environment}');
    } catch (e) {
      throw Exception('API Configuration validation failed: $e');
    }
  }

  // ─── Utility Methods ───────────────────────────────────────────────────────
  /// Gets the full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Gets configuration summary for debugging
  static Map<String, dynamic> getConfigurationSummary() {
    return {
      'base_url': baseUrl,
      'environment': AppConfig.environment,
      'is_production': isProductionEnvironment,
      'app_name': AppConfig.appName,
      'app_version': AppConfig.appVersion,
    };
  }
}