// BenchmarkingDataModel and BenchmarkInsightModel moved to CV Intelligence module
// Use: import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

import '../../../cv_intelligence/data/models/cv_intelligence_models.dart';

class ScoreSnapshotModel {
  final String id;
  final String snapshotType;
  final String triggerEvent;
  final int overallScore;
  final int completionPercentage;
  final int profileScore;
  final int experienceScore;
  final int educationScore;
  final int skillsScore;
  final int projectsScore;
  final bool submissionReady;
  final String grade;
  final double? percentileRank;
  final int peerGroupSize;
  final Map<String, dynamic> metricsData;
  final DateTime createdAt;

  const ScoreSnapshotModel({
    required this.id,
    required this.snapshotType,
    required this.triggerEvent,
    required this.overallScore,
    required this.completionPercentage,
    required this.profileScore,
    required this.experienceScore,
    required this.educationScore,
    required this.skillsScore,
    required this.projectsScore,
    required this.submissionReady,
    required this.grade,
    this.percentileRank,
    required this.peerGroupSize,
    required this.metricsData,
    required this.createdAt,
  });

  factory ScoreSnapshotModel.fromJson(Map<String, dynamic> json) {
    return ScoreSnapshotModel(
      id: json['id'] ?? '',
      snapshotType: json['snapshot_type'] ?? '',
      triggerEvent: json['trigger_event'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      completionPercentage: json['completion_percentage'] ?? 0,
      profileScore: json['profile_score'] ?? 0,
      experienceScore: json['experience_score'] ?? 0,
      educationScore: json['education_score'] ?? 0,
      skillsScore: json['skills_score'] ?? 0,
      projectsScore: json['projects_score'] ?? 0,
      submissionReady: json['submission_ready'] ?? false,
      grade: json['grade'] ?? '',
      percentileRank: json['percentile_rank'] != null 
          ? double.tryParse(json['percentile_rank'].toString()) 
          : null,
      peerGroupSize: json['peer_group_size'] ?? 0,
      metricsData: json['metrics_data'] ?? {},
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class TrendAnalysisModel {
  final String trendDirection;
  final String trendStrength;
  final double slope;
  final double rSquared;
  final double absoluteChange;
  final double percentageChange;
  final double volatilityScore;
  final double? predictedNextValue;
  final Map<String, dynamic> confidenceInterval;
  final List<TrendDataPoint> dataPoints;
  final DateTime analysisStart;
  final DateTime analysisEnd;
  final int dataPointsCount;

  const TrendAnalysisModel({
    required this.trendDirection,
    required this.trendStrength,
    required this.slope,
    required this.rSquared,
    required this.absoluteChange,
    required this.percentageChange,
    required this.volatilityScore,
    this.predictedNextValue,
    required this.confidenceInterval,
    required this.dataPoints,
    required this.analysisStart,
    required this.analysisEnd,
    required this.dataPointsCount,
  });

  factory TrendAnalysisModel.fromJson(Map<String, dynamic> json) {
    return TrendAnalysisModel(
      trendDirection: json['trend_direction'] ?? 'stable',
      trendStrength: json['trend_strength'] ?? 'weak',
      slope: (json['slope'] ?? 0.0).toDouble(),
      rSquared: (json['r_squared'] ?? 0.0).toDouble(),
      absoluteChange: (json['absolute_change'] ?? 0.0).toDouble(),
      percentageChange: (json['percentage_change'] ?? 0.0).toDouble(),
      volatilityScore: (json['volatility_score'] ?? 0.0).toDouble(),
      predictedNextValue: json['predicted_next_value'] != null 
          ? double.tryParse(json['predicted_next_value'].toString()) 
          : null,
      confidenceInterval: json['confidence_interval'] ?? {},
      dataPoints: (json['data_points'] as List<dynamic>?)
          ?.map((d) => TrendDataPoint.fromJson(d))
          .toList() ?? [],
      analysisStart: DateTime.parse(json['analysis_start'] ?? DateTime.now().toIso8601String()),
      analysisEnd: DateTime.parse(json['analysis_end'] ?? DateTime.now().toIso8601String()),
      dataPointsCount: json['data_points_count'] ?? 0,
    );
  }
}

class TrendDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  const TrendDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      value: (json['value'] ?? 0.0).toDouble(),
      label: json['label'],
    );
  }
}

class CompletionStatisticsModel {
  final String timePeriod;
  final int totalUsers;
  final double averageCompletion;
  final double averageScore;
  final int submissionReadyCount;
  final double submissionReadyPercentage;
  final Map<String, int> scoreDistribution;
  final Map<String, int> completionDistribution;
  final Map<String, double> sectionAverages;
  final List<StatisticsTrendPoint> trends;

  const CompletionStatisticsModel({
    required this.timePeriod,
    required this.totalUsers,
    required this.averageCompletion,
    required this.averageScore,
    required this.submissionReadyCount,
    required this.submissionReadyPercentage,
    required this.scoreDistribution,
    required this.completionDistribution,
    required this.sectionAverages,
    required this.trends,
  });

  factory CompletionStatisticsModel.fromJson(Map<String, dynamic> json) {
    return CompletionStatisticsModel(
      timePeriod: json['time_period'] ?? '',
      totalUsers: json['total_users'] ?? 0,
      averageCompletion: (json['average_completion'] ?? 0.0).toDouble(),
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      submissionReadyCount: json['submission_ready_count'] ?? 0,
      submissionReadyPercentage: (json['submission_ready_percentage'] ?? 0.0).toDouble(),
      scoreDistribution: Map<String, int>.from(json['score_distribution'] ?? {}),
      completionDistribution: Map<String, int>.from(json['completion_distribution'] ?? {}),
      sectionAverages: Map<String, double>.from(
        (json['section_averages'] ?? {}).map((k, v) => MapEntry(k, (v ?? 0.0).toDouble()))
      ),
      trends: (json['trends'] as List<dynamic>?)
          ?.map((t) => StatisticsTrendPoint.fromJson(t))
          .toList() ?? [],
    );
  }
}

class StatisticsTrendPoint {
  final DateTime date;
  final double averageScore;
  final double averageCompletion;
  final int userCount;

  const StatisticsTrendPoint({
    required this.date,
    required this.averageScore,
    required this.averageCompletion,
    required this.userCount,
  });

  factory StatisticsTrendPoint.fromJson(Map<String, dynamic> json) {
    return StatisticsTrendPoint(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      averageScore: (json['average_score'] ?? 0.0).toDouble(),
      averageCompletion: (json['average_completion'] ?? 0.0).toDouble(),
      userCount: json['user_count'] ?? 0,
    );
  }
}

class AnalyticsDashboardModel {
  final UserSummaryModel userSummary;
  final List<ScoreSnapshotModel> recentSnapshots;
  final TrendAnalysisModel? trendAnalysis;
  final Map<String, dynamic> benchmarkingSummary;
  final CompletionStatisticsModel? completionStats;
  final Map<String, dynamic> systemMetrics;

  const AnalyticsDashboardModel({
    required this.userSummary,
    required this.recentSnapshots,
    this.trendAnalysis,
    required this.benchmarkingSummary,
    this.completionStats,
    required this.systemMetrics,
  });

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboardModel(
      userSummary: UserSummaryModel.fromJson(json['user_summary'] ?? {}),
      recentSnapshots: (json['recent_snapshots'] as List<dynamic>?)
          ?.map((s) => ScoreSnapshotModel.fromJson(s))
          .toList() ?? [],
      trendAnalysis: json['trend_analysis'] != null 
          ? TrendAnalysisModel.fromJson(json['trend_analysis']) 
          : null,
      benchmarkingSummary: json['benchmarking_summary'] ?? {},
      completionStats: json['completion_stats'] != null 
          ? CompletionStatisticsModel.fromJson(json['completion_stats']) 
          : null,
      systemMetrics: json['system_metrics'] ?? {},
    );
  }
}

class UserSummaryModel {
  final int latestScore;
  final int latestCompletion;
  final bool submissionReady;
  final String grade;
  final double? percentileRank;
  final int totalSnapshots;

  const UserSummaryModel({
    required this.latestScore,
    required this.latestCompletion,
    required this.submissionReady,
    required this.grade,
    this.percentileRank,
    required this.totalSnapshots,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      latestScore: json['latest_score'] ?? 0,
      latestCompletion: json['latest_completion'] ?? 0,
      submissionReady: json['submission_ready'] ?? false,
      grade: json['grade'] ?? '',
      percentileRank: json['percentile_rank'] != null 
          ? double.tryParse(json['percentile_rank'].toString()) 
          : null,
      totalSnapshots: json['total_snapshots'] ?? 0,
    );
  }
}