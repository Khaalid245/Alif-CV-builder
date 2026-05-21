import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Centralized configuration management for EduCV Flutter app.
/// All hardcoded values should be moved here with environment variable support.
class AppConfig {
  // ─── API Configuration ─────────────────────────────────────────────────────
  static String get baseUrl {
    try {
      const buildTimeUrl = String.fromEnvironment('API_BASE_URL');
      final url = buildTimeUrl.isNotEmpty ? buildTimeUrl : dotenv.env['API_BASE_URL'];
      
      if (url == null || url.isEmpty) {
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
    final env = buildTimeEnv.isNotEmpty
        ? buildTimeEnv
        : dotenv.env['ENVIRONMENT'] ?? 'development';
    return env.toLowerCase() == 'production';
  }

  static String get environment {
    const buildTimeEnv = String.fromEnvironment('ENVIRONMENT');
    return buildTimeEnv.isNotEmpty
        ? buildTimeEnv
        : dotenv.env['ENVIRONMENT'] ?? 'development';
  }

  // ─── Configurable API URLs ─────────────────────────────────────────────────
  static String get developmentApiUrl => 
      dotenv.env['DEVELOPMENT_API_URL'] ?? 'http://localhost:8000/api/v1';
  
  static String get productionApiUrl => 
      dotenv.env['PRODUCTION_API_URL'] ?? 'https://api.yourdomain.com/api/v1';

  // ─── App Information ───────────────────────────────────────────────────────
  static String get appName => dotenv.env['APP_NAME'] ?? 'EduCV';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appDescription => dotenv.env['APP_DESCRIPTION'] ?? 
      'Enterprise University CV Builder Platform';

  // ─── UI Configuration ──────────────────────────────────────────────────────
  static int get defaultPageSize => 
      int.tryParse(dotenv.env['DEFAULT_PAGE_SIZE'] ?? '') ?? 20;
  
  static int get maxPageSize => 
      int.tryParse(dotenv.env['MAX_PAGE_SIZE'] ?? '') ?? 100;
  
  static int get adminPageSize => 
      int.tryParse(dotenv.env['ADMIN_PAGE_SIZE'] ?? '') ?? 50;

  // ─── File Upload Limits ────────────────────────────────────────────────────
  static int get maxUploadSizeMB => 
      int.tryParse(dotenv.env['MAX_UPLOAD_SIZE_MB'] ?? '') ?? 5;
  
  static int get maxProfilePhotoSizeMB => 
      int.tryParse(dotenv.env['MAX_PROFILE_PHOTO_SIZE_MB'] ?? '') ?? 2;
  
  static List<String> get allowedImageFormats => 
      (dotenv.env['ALLOWED_IMAGE_FORMATS'] ?? 'jpg,jpeg,png,webp').split(',');

  // ─── Cache Configuration ───────────────────────────────────────────────────
  static Duration get cacheTimeoutShort => Duration(
    minutes: int.tryParse(dotenv.env['CACHE_TIMEOUT_SHORT_MINUTES'] ?? '') ?? 5
  );
  
  static Duration get cacheTimeoutMedium => Duration(
    minutes: int.tryParse(dotenv.env['CACHE_TIMEOUT_MEDIUM_MINUTES'] ?? '') ?? 30
  );
  
  static Duration get cacheTimeoutLong => Duration(
    hours: int.tryParse(dotenv.env['CACHE_TIMEOUT_LONG_HOURS'] ?? '') ?? 1
  );

  // ─── CV Intelligence Configuration ─────────────────────────────────────────
  static Map<String, int> get cvScoringWeights => {
    'profile': int.tryParse(dotenv.env['CV_PROFILE_WEIGHT'] ?? '') ?? 25,
    'experience': int.tryParse(dotenv.env['CV_EXPERIENCE_WEIGHT'] ?? '') ?? 25,
    'education': int.tryParse(dotenv.env['CV_EDUCATION_WEIGHT'] ?? '') ?? 20,
    'skills': int.tryParse(dotenv.env['CV_SKILLS_WEIGHT'] ?? '') ?? 15,
    'projects': int.tryParse(dotenv.env['CV_PROJECTS_WEIGHT'] ?? '') ?? 15,
  };

  static Map<String, int> get submissionReadinessThresholds => {
    'overall_score': int.tryParse(dotenv.env['SUBMISSION_MIN_OVERALL_SCORE'] ?? '') ?? 70,
    'profile_score': int.tryParse(dotenv.env['SUBMISSION_MIN_PROFILE_SCORE'] ?? '') ?? 60,
    'experience_score': int.tryParse(dotenv.env['SUBMISSION_MIN_EXPERIENCE_SCORE'] ?? '') ?? 60,
    'education_score': int.tryParse(dotenv.env['SUBMISSION_MIN_EDUCATION_SCORE'] ?? '') ?? 60,
    'skills_score': int.tryParse(dotenv.env['SUBMISSION_MIN_SKILLS_SCORE'] ?? '') ?? 60,
    'projects_score': int.tryParse(dotenv.env['SUBMISSION_MIN_PROJECTS_SCORE'] ?? '') ?? 50,
  };

  static Map<String, int> get gradeBoundaries => {
    'A': int.tryParse(dotenv.env['GRADE_A_THRESHOLD'] ?? '') ?? 90,
    'B': int.tryParse(dotenv.env['GRADE_B_THRESHOLD'] ?? '') ?? 80,
    'C': int.tryParse(dotenv.env['GRADE_C_THRESHOLD'] ?? '') ?? 70,
    'D': int.tryParse(dotenv.env['GRADE_D_THRESHOLD'] ?? '') ?? 60,
  };

  // ─── Template Configuration ────────────────────────────────────────────────
  static List<String> get templateTypes => 
      (dotenv.env['TEMPLATE_TYPES'] ?? 'classic,modern,academic').split(',');
  
  static String get defaultTemplate => 
      dotenv.env['DEFAULT_TEMPLATE'] ?? 'modern';

  // ─── Business Rules ────────────────────────────────────────────────────────
  static int get maxExperienceEntries => 
      int.tryParse(dotenv.env['MAX_EXPERIENCE_ENTRIES'] ?? '') ?? 10;
  
  static int get maxEducationEntries => 
      int.tryParse(dotenv.env['MAX_EDUCATION_ENTRIES'] ?? '') ?? 5;
  
  static int get maxProjectEntries => 
      int.tryParse(dotenv.env['MAX_PROJECT_ENTRIES'] ?? '') ?? 10;
  
  static int get maxCertificationEntries => 
      int.tryParse(dotenv.env['MAX_CERTIFICATION_ENTRIES'] ?? '') ?? 15;

  // ─── Notification Configuration ────────────────────────────────────────────
  static int get notificationBatchSize => 
      int.tryParse(dotenv.env['NOTIFICATION_BATCH_SIZE'] ?? '') ?? 100;
  
  static int get notificationRetentionDays => 
      int.tryParse(dotenv.env['NOTIFICATION_RETENTION_DAYS'] ?? '') ?? 90;

  // ─── Analytics Configuration ───────────────────────────────────────────────
  static int get analyticsRetentionDays => 
      int.tryParse(dotenv.env['ANALYTICS_RETENTION_DAYS'] ?? '') ?? 365;
  
  static int get snapshotIntervalHours => 
      int.tryParse(dotenv.env['SNAPSHOT_INTERVAL_HOURS'] ?? '') ?? 24;

  // ─── Network Configuration ─────────────────────────────────────────────────
  static Duration get networkTimeout => Duration(
    seconds: int.tryParse(dotenv.env['NETWORK_TIMEOUT_SECONDS'] ?? '') ?? 30
  );
  
  static Duration get connectionTimeout => Duration(
    seconds: int.tryParse(dotenv.env['CONNECTION_TIMEOUT_SECONDS'] ?? '') ?? 10
  );
  
  static int get maxRetryAttempts => 
      int.tryParse(dotenv.env['MAX_RETRY_ATTEMPTS'] ?? '') ?? 3;

  // ─── Debug Configuration ───────────────────────────────────────────────────
  static bool get enableDebugLogging => 
      (dotenv.env['ENABLE_DEBUG_LOGGING'] ?? 'false').toLowerCase() == 'true';
  
  static bool get enablePerformanceLogging => 
      (dotenv.env['ENABLE_PERFORMANCE_LOGGING'] ?? 'false').toLowerCase() == 'true';
  
  static bool get enableNetworkLogging => 
      (dotenv.env['ENABLE_NETWORK_LOGGING'] ?? 'false').toLowerCase() == 'true';

  // ─── Feature Flags ─────────────────────────────────────────────────────────
  static bool get enableAnalytics => 
      (dotenv.env['ENABLE_ANALYTICS'] ?? 'true').toLowerCase() == 'true';
  
  static bool get enableNotifications => 
      (dotenv.env['ENABLE_NOTIFICATIONS'] ?? 'true').toLowerCase() == 'true';
  
  static bool get enableVersionHistory => 
      (dotenv.env['ENABLE_VERSION_HISTORY'] ?? 'true').toLowerCase() == 'true';
  
  static bool get enableTemplateEngine => 
      (dotenv.env['ENABLE_TEMPLATE_ENGINE'] ?? 'true').toLowerCase() == 'true';

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
      await dotenv.load(fileName: "assets/env/.env");
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