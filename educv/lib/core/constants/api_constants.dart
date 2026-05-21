import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    try {
      const buildTimeUrl = String.fromEnvironment('API_BASE_URL');
      final url =
          buildTimeUrl.isNotEmpty ? buildTimeUrl : dotenv.env['API_BASE_URL'];
      
      // CRITICAL: Fail fast if API URL is not configured
      if (url == null || url.isEmpty) {
        throw Exception(
          'FATAL: API_BASE_URL environment variable not set. '
          'Please configure assets/env/.env with a valid backend URL. '
          'Development: http://localhost:8000/api/v1 '
          'Production: https://api.yourdomain.com/api/v1',
        );
      }
      
      // Validate that URL is not localhost in production
      if (_isProductionEnvironment && url.contains('localhost')) {
        throw Exception(
          'FATAL: localhost URL detected in production environment. '
          'Please update API_BASE_URL to your production server URL.'
        );
      }
      
      return url;
    } catch (e) {
      // Fallback for development
      print('ApiConstants.baseUrl error: $e');
      return 'http://localhost:8000/api/v1';
    }
  }

  // Helper to check if running in production
  static bool get _isProductionEnvironment {
    const buildTimeEnv = String.fromEnvironment('ENVIRONMENT');
    final env = buildTimeEnv.isNotEmpty
        ? buildTimeEnv
        : dotenv.env['ENVIRONMENT'] ?? 'development';
    return env.toLowerCase() == 'production';
  }

  // Auth
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
  static String cvDownload(String generatedCvId) =>
      '/cv/download/$generatedCvId/';
  static const String announcement = '/cv/announcement/';

  // CV Intelligence
  static const String cvAnalyze = '/cv/analyze/';
  static const String cvScore = '/cv/score/';
  static const String cvDashboard = '/cv/dashboard/';
  static const String cvAnalysisHistory = '/cv/intelligence/analysis/history/';
  static String cvAnalysisHistoryDetail(String historyId) => '/cv/intelligence/analysis/history/$historyId/';
  static const String cvBenchmarking = '/cv/benchmarking/';
  static const String cvExportAnalysis = '/cv/export-analysis/';

  // CV Intelligence - Legacy endpoints for backward compatibility
  static const String cvIntelligenceAnalysisHistory = '/cv/analysis/history/';
  static String cvIntelligenceAnalysisHistoryDetail(String historyId) => '/cv/analysis/history/$historyId/';

  // Workflow Control System
  static const String workflowInstances = '/workflow/instances/';
  static const String workflowConfigurations = '/workflow/configurations/';
  static String workflowTransition(String instanceId) => '/workflow/instances/$instanceId/transition/';
  static String workflowCV(String cvId) => '/workflow/cv/$cvId/';
  static const String workflowDashboard = '/workflow/dashboard/';

  // Version History
  static const String versionHistory = '/version-history/versions/';
  static String versionDetail(String versionId) => '/version-history/versions/$versionId/';
  static const String versionCompare = '/version-history/compare/';
  static const String versionRestore = '/version-history/restore/';
  static const String versionStats = '/version-history/stats/';

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

  // Analytics
  static const String analyticsDashboard = '/analytics/dashboard/';
  static const String analyticsSnapshots = '/analytics/snapshots/';
  static const String createSnapshot = '/analytics/snapshots/create/';
  static const String trendAnalysis = '/analytics/trend-analysis/';
  static const String benchmarking = '/analytics/benchmarking/';
  static const String completionStatistics = '/analytics/completion-statistics/';

  // Notifications
  static const String notifications = '/notifications/';
  static const String notificationStats = '/notifications/stats/';
  static const String notificationPreferences = '/notifications/preferences/';
  static String markNotificationRead(String id) => '/notifications/$id/mark_read/';
  static const String markMultipleNotificationsRead = '/notifications/mark_multiple_read/';

  // Template Engine
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

  // Template Engine - Additional constants
  static const String industries = '/templates/industries/';
  static const String roles = '/templates/roles/';
  static const String categories = '/templates/categories/';
  static const String recommendedTemplates = '/templates/templates/recommendations/';
  static const String popularTemplates = '/templates/templates/popular/';
}