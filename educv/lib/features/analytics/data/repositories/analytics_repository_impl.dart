import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/analytics_repository.dart';
import '../models/analytics_models.dart';
import '../../../cv_intelligence/data/models/cv_intelligence_models.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepositoryImpl(this._apiClient);

  @override
  Future<AnalyticsDashboardModel> getDashboardData() async {
    final response = await _apiClient.get('/analytics/dashboard/');
    
    if (response.success && response.data != null) {
      return AnalyticsDashboardModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch dashboard data');
  }

  @override
  Future<List<ScoreSnapshotModel>> getScoreSnapshots({
    String? snapshotType,
    bool? submissionReady,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    
    if (snapshotType != null) queryParams['snapshot_type'] = snapshotType;
    if (submissionReady != null) queryParams['submission_ready'] = submissionReady.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _apiClient.get(
      '/analytics/snapshots/',
      queryParameters: queryParams,
    );
    
    if (response.success && response.data != null) {
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => ScoreSnapshotModel.fromJson(json)).toList();
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch score snapshots');
  }

  @override
  Future<TrendAnalysisModel> getTrendAnalysis({
    required int days,
    String? metric,
  }) async {
    final response = await _apiClient.post(
      '/analytics/trend-analysis/',
      data: {
        'days': days,
        if (metric != null) 'metric': metric,
      },
    );
    
    if (response.success && response.data != null) {
      return TrendAnalysisModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch trend analysis');
  }

  @override
  Future<BenchmarkingDataModel> getBenchmarkingData({
    List<String>? groupTypes,
  }) async {
    final response = await _apiClient.post(
      '/analytics/benchmarking/',
      data: {
        if (groupTypes != null) 'group_types': groupTypes,
      },
    );
    
    if (response.success && response.data != null) {
      return BenchmarkingDataModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch benchmarking data');
  }

  @override
  Future<CompletionStatisticsModel> getCompletionStatistics({
    String? groupType,
    required int timePeriod,
  }) async {
    final response = await _apiClient.post(
      '/analytics/completion-statistics/',
      data: {
        'time_period': timePeriod,
        if (groupType != null) 'group_type': groupType,
      },
    );
    
    if (response.success && response.data != null) {
      return CompletionStatisticsModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch completion statistics');
  }

  @override
  Future<ScoreSnapshotModel> createSnapshot({
    required String snapshotType,
    String? triggerEvent,
  }) async {
    final response = await _apiClient.post(
      '/analytics/snapshots/create/',
      data: {
        'snapshot_type': snapshotType,
        if (triggerEvent != null) 'trigger_event': triggerEvent,
      },
    );
    
    if (response.success && response.data != null) {
      return ScoreSnapshotModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to create snapshot');
  }
}