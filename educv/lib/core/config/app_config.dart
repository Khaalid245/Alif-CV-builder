import 'env.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Centralized configuration management for EduCV Flutter app.
/// All hardcoded values should be moved here with environment variable support.
class AppConfig {
  // ─── API Configuration ─────────────────────────────────────────────────────
  static String get baseUrl {
    try {
      const buildTimeUrl = String.fromEnvironment('API_BASE_URL');
      final url = buildTimeUrl.isNotEmpty ? buildTimeUrl : Env.apiBaseUrl;

      if (url.isEmpty) {
        return _getDefaultApiUrl();
      }

      // Auto-detect platform and adjust URL if needed
      return _adjustUrlForPlatform(url);
    } catch (e) {
      print('AppConfig.baseUrl error: $e');
      return _getDefaultApiUrl();
    }
  }

  /// Automatically detects platform and returns appropriate API URL
  static String _getDefaultApiUrl() {
    if (kIsWeb) {
      // Web browsers (Chrome, Firefox, etc.)
      return 'http://localhost:8000/api/v1';
    } else if (Platform.isAndroid) {
      // Android emulator
      return 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      // iOS simulator
      return 'http://localhost:8000/api/v1';
    } else {
      // Desktop (Windows, macOS, Linux)
      return 'http://localhost:8000/api/v1';
    }
  }

  /// Adjusts URL based on current platform
  static String _adjustUrlForPlatform(String url) {
    // If URL contains 10.0.2.2 but we're not on Android, convert to localhost
    if (url.contains('10.0.2.2') && !Platform.isAndroid) {
      return url.replaceAll('10.0.2.2', 'localhost');
    }

    // If URL contains localhost but we're on Android, convert to 10.0.2.2
    if (url.contains('localhost') && Platform.isAndroid && !kIsWeb) {
      return url.replaceAll('localhost', '10.0.2.2');
    }

    return url;
  }

  // ─── Environment Configuration ─────────────────────────────────────────────
  static bool get _isProductionEnvironment {
    const buildTimeEnv = String.fromEnvironment('ENVIRONMENT');
    final env = buildTimeEnv.isNotEmpty ? buildTimeEnv : Env.environment;
    return env.toLowerCase() == 'production';
  }

  static String get environment {
    const buildTimeEnv = String.fromEnvironment('ENVIRONMENT');
    return buildTimeEnv.isNotEmpty ? buildTimeEnv : Env.environment;
  }

  // ─── Configurable API URLs ─────────────────────────────────────────────────
  static String get developmentApiUrl => 'http://localhost:8000/api/v1';

  static String get productionApiUrl => 'https://api.yourdomain.com/api/v1';

  // ─── App Information ───────────────────────────────────────────────────────
  static String get appName => Env.appName;
  static String get appVersion => Env.appVersion;
  static String get appDescription =>
      dotenv.env['APP_DESCRIPTION'] ??
      'Enterprise University CV Builder Platform';

  // ─── UI Configuration ──────────────────────────────────────────────────────
  static int get defaultPageSize => 20;

  static int get maxPageSize => 100;

  static int get adminPageSize => 50;

  // ─── File Upload Limits ────────────────────────────────────────────────────
  static int get maxUploadSizeMB => 5;

  static int get maxProfilePhotoSizeMB => 2;

  static List<String> get allowedImageFormats => 'jpg,jpeg,png,webp'.split(',');

  // ─── Cache Configuration ───────────────────────────────────────────────────
  static Duration get cacheTimeoutShort => const Duration(minutes: 5);

  static Duration get cacheTimeoutMedium => const Duration(minutes: 30);

  static Duration get cacheTimeoutLong => const Duration(hours: 1);

  // ─── CV Intelligence Configuration ─────────────────────────────────────────
  static Map<String, int> get cvScoringWeights => {
        'profile': 25,
        'experience': 25,
        'education': 20,
        'skills': 15,
        'projects': 15,
      };

  static Map<String, int> get submissionReadinessThresholds => {
        'overall_score': 70,
        'profile_score': 60,
        'experience_score': 60,
        'education_score': 60,
        'skills_score': 60,
        'projects_score': 50,
      };

  static Map<String, int> get gradeBoundaries => {
        'A': 90,
        'B': 80,
        'C': 70,
        'D': 60,
      };

  // ─── Template Configuration ────────────────────────────────────────────────
  static List<String> get templateTypes => 'classic,modern,academic'.split(',');

  static String get defaultTemplate => 'modern';

  // ─── Business Rules ────────────────────────────────────────────────────────
  static int get maxExperienceEntries => 10;

  static int get maxEducationEntries => 5;

  static int get maxProjectEntries => 10;

  static int get maxCertificationEntries => 15;

  // ─── Notification Configuration ────────────────────────────────────────────
  static int get notificationBatchSize => 100;

  static int get notificationRetentionDays => 90;

  // ─── Analytics Configuration ───────────────────────────────────────────────
  static int get analyticsRetentionDays => 365;

  static int get snapshotIntervalHours => 24;

  // ─── Network Configuration ─────────────────────────────────────────────────
  static Duration get networkTimeout => const Duration(seconds: 30);

  static Duration get connectionTimeout => const Duration(seconds: 10);

  static int get maxRetryAttempts => 3;

  // ─── Debug Configuration ───────────────────────────────────────────────────
  static bool get enableDebugLogging => ('false').toLowerCase() == 'true';

  static bool get enablePerformanceLogging => ('false').toLowerCase() == 'true';

  static bool get enableNetworkLogging => ('false').toLowerCase() == 'true';

  // ─── Feature Flags ─────────────────────────────────────────────────────────
  static bool get enableAnalytics => ('true').toLowerCase() == 'true';

  static bool get enableNotifications => ('true').toLowerCase() == 'true';

  static bool get enableVersionHistory => ('true').toLowerCase() == 'true';

  static bool get enableTemplateEngine => ('true').toLowerCase() == 'true';

  // ─── Validation Methods ────────────────────────────────────────────────────
  static bool validateScoringWeights() {
    final weights = cvScoringWeights;
    final total = weights.values.reduce((a, b) => a + b);
    if (total != 100) {
      throw Exception('CV scoring weights must sum to 100, got $total');
    }
    return true;
  }

  static Map<String, dynamic> getConfigSummary() {
    return {
      'app_name': appName,
      'app_version': appVersion,
      'environment': environment,
      'api_base_url': baseUrl,
      'template_types': templateTypes,
      'default_template': defaultTemplate,
      'max_upload_size_mb': maxUploadSizeMB,
      'default_page_size': defaultPageSize,
      'feature_flags': {
        'analytics': enableAnalytics,
        'notifications': enableNotifications,
        'version_history': enableVersionHistory,
        'template_engine': enableTemplateEngine,
      },
      'cv_scoring_weights': cvScoringWeights,
      'submission_thresholds': submissionReadinessThresholds,
      'grade_boundaries': gradeBoundaries,
    };
  }

  // ─── Initialization ────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    try {
      validateScoringWeights();

      if (enableDebugLogging) {
        print('AppConfig initialized successfully');
        print('Configuration summary: ${getConfigSummary()}');
      }
    } catch (e) {
      print('AppConfig initialization error: $e');
      rethrow;
    }
  }
}
