import '../data/models/analytics_models.dart';
import '../../cv_intelligence/data/models/cv_intelligence_models.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsDashboardModel> getDashboardData();
  
  Future<List<ScoreSnapshotModel>> getScoreSnapshots({
    String? snapshotType,
    bool? submissionReady,
    int? limit,
    int? offset,
  });
  
  Future<TrendAnalysisModel> getTrendAnalysis({
    required int days,
    String? metric,
  });
  
  Future<BenchmarkingDataModel> getBenchmarkingData({
    List<String>? groupTypes,
  });
  
  Future<CompletionStatisticsModel> getCompletionStatistics({
    String? groupType,
    required int timePeriod,
  });
  
  Future<ScoreSnapshotModel> createSnapshot({
    required String snapshotType,
    String? triggerEvent,
  });
}