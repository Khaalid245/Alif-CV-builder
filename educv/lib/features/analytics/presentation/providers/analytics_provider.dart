import 'package:flutter/foundation.dart';
import '../../data/models/analytics_models.dart';
import '../../domain/analytics_repository.dart';
import '../../../cv_intelligence/data/models/cv_intelligence_models.dart';

enum AnalyticsState { initial, loading, loaded, error }

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsProvider(this._repository);

  AnalyticsState _state = AnalyticsState.initial;
  AnalyticsDashboardModel? _dashboardData;
  List<ScoreSnapshotModel> _snapshots = [];
  TrendAnalysisModel? _trendAnalysis;
  BenchmarkingDataModel? _benchmarkingData;
  CompletionStatisticsModel? _completionStats;
  String? _errorMessage;

  // Filters
  String? _selectedSnapshotType;
  bool? _submissionReadyFilter;
  int _trendDays = 30;
  int _statsPeriod = 30;

  AnalyticsState get state => _state;
  AnalyticsDashboardModel? get dashboardData => _dashboardData;
  List<ScoreSnapshotModel> get snapshots => _snapshots;
  TrendAnalysisModel? get trendAnalysis => _trendAnalysis;
  BenchmarkingDataModel? get benchmarkingData => _benchmarkingData;
  CompletionStatisticsModel? get completionStats => _completionStats;
  String? get errorMessage => _errorMessage;
  String? get selectedSnapshotType => _selectedSnapshotType;
  bool? get submissionReadyFilter => _submissionReadyFilter;
  int get trendDays => _trendDays;
  int get statsPeriod => _statsPeriod;

  Future<void> loadDashboardData() async {
    _setState(AnalyticsState.loading);
    
    try {
      _dashboardData = await _repository.getDashboardData();
      _setState(AnalyticsState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AnalyticsState.error);
    }
  }

  Future<void> loadSnapshots() async {
    try {
      _snapshots = await _repository.getScoreSnapshots(
        snapshotType: _selectedSnapshotType,
        submissionReady: _submissionReadyFilter,
        limit: 50,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadTrendAnalysis() async {
    try {
      _trendAnalysis = await _repository.getTrendAnalysis(
        days: _trendDays,
        metric: 'overall_score',
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadBenchmarkingData() async {
    try {
      _benchmarkingData = await _repository.getBenchmarkingData();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadCompletionStatistics() async {
    try {
      _completionStats = await _repository.getCompletionStatistics(
        timePeriod: _statsPeriod,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> createSnapshot({
    required String snapshotType,
    String? triggerEvent,
  }) async {
    try {
      final snapshot = await _repository.createSnapshot(
        snapshotType: snapshotType,
        triggerEvent: triggerEvent,
      );
      
      // Add to local list
      _snapshots.insert(0, snapshot);
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void setSnapshotTypeFilter(String? type) {
    _selectedSnapshotType = type;
    notifyListeners();
    loadSnapshots();
  }

  void setSubmissionReadyFilter(bool? ready) {
    _submissionReadyFilter = ready;
    notifyListeners();
    loadSnapshots();
  }

  void setTrendDays(int days) {
    _trendDays = days;
    notifyListeners();
    loadTrendAnalysis();
  }

  void setStatsPeriod(int period) {
    _statsPeriod = period;
    notifyListeners();
    loadCompletionStatistics();
  }

  void clearFilters() {
    _selectedSnapshotType = null;
    _submissionReadyFilter = null;
    notifyListeners();
    loadSnapshots();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void refreshAll() {
    loadDashboardData();
    loadSnapshots();
    loadTrendAnalysis();
    loadBenchmarkingData();
    loadCompletionStatistics();
  }

  void _setState(AnalyticsState newState) {
    _state = newState;
    notifyListeners();
  }
}