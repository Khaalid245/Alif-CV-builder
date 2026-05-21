import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:educv/features/analytics/data/models/analytics_models.dart';
import 'package:educv/features/analytics/domain/analytics_repository.dart';
import 'package:educv/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

import 'analytics_provider_test.mocks.dart';

@GenerateMocks([AnalyticsRepository])
void main() {
  late MockAnalyticsRepository mockRepository;
  late AnalyticsProvider provider;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    provider = AnalyticsProvider(mockRepository);
  });

  group('AnalyticsProvider', () {
    test('initial state should be correct', () {
      expect(provider.state, AnalyticsState.initial);
      expect(provider.dashboardData, null);
      expect(provider.snapshots, isEmpty);
      expect(provider.trendAnalysis, null);
      expect(provider.benchmarkingData, null);
      expect(provider.completionStats, null);
      expect(provider.errorMessage, null);
      expect(provider.selectedSnapshotType, null);
      expect(provider.submissionReadyFilter, null);
      expect(provider.trendDays, 30);
      expect(provider.statsPeriod, 30);
    });

    test('loadDashboardData should update state correctly on success', () async {
      final mockDashboard = AnalyticsDashboardModel(
        userSummary: UserSummaryModel(
          latestScore: 85,
          latestCompletion: 90,
          submissionReady: true,
          grade: 'A',
          percentileRank: 75.5,
          totalSnapshots: 10,
        ),
        recentSnapshots: [],
        benchmarkingSummary: {},
        systemMetrics: {},
      );

      when(mockRepository.getDashboardData()).thenAnswer((_) async => mockDashboard);

      await provider.loadDashboardData();

      expect(provider.state, AnalyticsState.loaded);
      expect(provider.dashboardData, mockDashboard);
      expect(provider.errorMessage, null);
    });

    test('loadDashboardData should handle errors correctly', () async {
      when(mockRepository.getDashboardData()).thenThrow(Exception('Network error'));

      await provider.loadDashboardData();

      expect(provider.state, AnalyticsState.error);
      expect(provider.dashboardData, null);
      expect(provider.errorMessage, 'Exception: Network error');
    });

    test('loadSnapshots should update snapshots on success', () async {
      final mockSnapshots = [
        ScoreSnapshotModel(
          id: '1',
          snapshotType: 'manual',
          triggerEvent: 'Test',
          overallScore: 85,
          completionPercentage: 90,
          profileScore: 80,
          experienceScore: 85,
          educationScore: 90,
          skillsScore: 88,
          projectsScore: 82,
          submissionReady: true,
          grade: 'A',
          peerGroupSize: 100,
          metricsData: {},
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getScoreSnapshots(
        snapshotType: null,
        submissionReady: null,
        limit: 50,
      )).thenAnswer((_) async => mockSnapshots);

      await provider.loadSnapshots();

      expect(provider.snapshots, mockSnapshots);
      expect(provider.errorMessage, null);
    });

    test('loadTrendAnalysis should update trend analysis on success', () async {
      final mockTrend = TrendAnalysisModel(
        trendDirection: 'improving',
        trendStrength: 'strong',
        slope: 2.5,
        rSquared: 0.85,
        absoluteChange: 15.0,
        percentageChange: 20.0,
        volatilityScore: 3.0,
        confidenceInterval: {},
        dataPoints: [],
        analysisStart: DateTime.now().subtract(const Duration(days: 30)),
        analysisEnd: DateTime.now(),
        dataPointsCount: 10,
      );

      when(mockRepository.getTrendAnalysis(
        days: 30,
        metric: 'overall_score',
      )).thenAnswer((_) async => mockTrend);

      await provider.loadTrendAnalysis();

      expect(provider.trendAnalysis, mockTrend);
      expect(provider.errorMessage, null);
    });

    test('loadBenchmarkingData should update benchmarking data on success', () async {
      final mockBenchmarking = BenchmarkingDataModel(
        userId: 'user-123',
        currentScore: 85.5,
        percentileRank: 75.0,
        totalPeers: 200,
        groups: [],
        summary: {'performance': 'above_average'},
        peerComparisons: [],
      );

      when(mockRepository.getBenchmarkingData()).thenAnswer((_) async => mockBenchmarking);

      await provider.loadBenchmarkingData();

      expect(provider.benchmarkingData, mockBenchmarking);
      expect(provider.errorMessage, null);
    });

    test('loadCompletionStatistics should update completion stats on success', () async {
      final mockStats = CompletionStatisticsModel(
        timePeriod: '30',
        totalUsers: 1000,
        averageCompletion: 75.5,
        averageScore: 82.3,
        submissionReadyCount: 650,
        submissionReadyPercentage: 65.0,
        scoreDistribution: {},
        completionDistribution: {},
        sectionAverages: {},
        trends: [],
      );

      when(mockRepository.getCompletionStatistics(
        timePeriod: 30,
      )).thenAnswer((_) async => mockStats);

      await provider.loadCompletionStatistics();

      expect(provider.completionStats, mockStats);
      expect(provider.errorMessage, null);
    });

    test('createSnapshot should add snapshot to list on success', () async {
      final mockSnapshot = ScoreSnapshotModel(
        id: 'new-snapshot',
        snapshotType: 'manual',
        triggerEvent: 'User created',
        overallScore: 88,
        completionPercentage: 95,
        profileScore: 85,
        experienceScore: 90,
        educationScore: 92,
        skillsScore: 90,
        projectsScore: 85,
        submissionReady: true,
        grade: 'A',
        peerGroupSize: 120,
        metricsData: {},
        createdAt: DateTime.now(),
      );

      when(mockRepository.createSnapshot(
        snapshotType: 'manual',
        triggerEvent: 'Test snapshot',
      )).thenAnswer((_) async => mockSnapshot);

      final result = await provider.createSnapshot(
        snapshotType: 'manual',
        triggerEvent: 'Test snapshot',
      );

      expect(result, true);
      expect(provider.snapshots.first, mockSnapshot);
      expect(provider.errorMessage, null);
    });

    test('createSnapshot should return false on error', () async {
      when(mockRepository.createSnapshot(
        snapshotType: 'manual',
        triggerEvent: 'Test snapshot',
      )).thenThrow(Exception('Creation failed'));

      final result = await provider.createSnapshot(
        snapshotType: 'manual',
        triggerEvent: 'Test snapshot',
      );

      expect(result, false);
      expect(provider.errorMessage, 'Exception: Creation failed');
    });

    test('setSnapshotTypeFilter should update filter and reload snapshots', () async {
      when(mockRepository.getScoreSnapshots(
        snapshotType: 'manual',
        submissionReady: null,
        limit: 50,
      )).thenAnswer((_) async => []);

      provider.setSnapshotTypeFilter('manual');

      expect(provider.selectedSnapshotType, 'manual');
      verify(mockRepository.getScoreSnapshots(
        snapshotType: 'manual',
        submissionReady: null,
        limit: 50,
      )).called(1);
    });

    test('setSubmissionReadyFilter should update filter and reload snapshots', () async {
      when(mockRepository.getScoreSnapshots(
        snapshotType: null,
        submissionReady: true,
        limit: 50,
      )).thenAnswer((_) async => []);

      provider.setSubmissionReadyFilter(true);

      expect(provider.submissionReadyFilter, true);
      verify(mockRepository.getScoreSnapshots(
        snapshotType: null,
        submissionReady: true,
        limit: 50,
      )).called(1);
    });

    test('setTrendDays should update days and reload trend analysis', () async {
      when(mockRepository.getTrendAnalysis(
        days: 90,
        metric: 'overall_score',
      )).thenAnswer((_) async => TrendAnalysisModel(
        trendDirection: 'stable',
        trendStrength: 'weak',
        slope: 0.1,
        rSquared: 0.2,
        absoluteChange: 1.0,
        percentageChange: 1.5,
        volatilityScore: 1.0,
        confidenceInterval: {},
        dataPoints: [],
        analysisStart: DateTime.now(),
        analysisEnd: DateTime.now(),
        dataPointsCount: 0,
      ));

      provider.setTrendDays(90);

      expect(provider.trendDays, 90);
      verify(mockRepository.getTrendAnalysis(
        days: 90,
        metric: 'overall_score',
      )).called(1);
    });

    test('setStatsPeriod should update period and reload completion statistics', () async {
      when(mockRepository.getCompletionStatistics(
        timePeriod: 90,
      )).thenAnswer((_) async => CompletionStatisticsModel(
        timePeriod: '90',
        totalUsers: 500,
        averageCompletion: 70.0,
        averageScore: 75.0,
        submissionReadyCount: 300,
        submissionReadyPercentage: 60.0,
        scoreDistribution: {},
        completionDistribution: {},
        sectionAverages: {},
        trends: [],
      ));

      provider.setStatsPeriod(90);

      expect(provider.statsPeriod, 90);
      verify(mockRepository.getCompletionStatistics(
        timePeriod: 90,
      )).called(1);
    });

    test('clearFilters should reset filters and reload snapshots', () async {
      // Set some filters first
      provider.setSnapshotTypeFilter('manual');
      provider.setSubmissionReadyFilter(true);

      when(mockRepository.getScoreSnapshots(
        snapshotType: null,
        submissionReady: null,
        limit: 50,
      )).thenAnswer((_) async => []);

      provider.clearFilters();

      expect(provider.selectedSnapshotType, null);
      expect(provider.submissionReadyFilter, null);
    });

    test('refreshAll should call all load methods', () async {
      // Mock all repository methods
      when(mockRepository.getDashboardData()).thenAnswer((_) async => AnalyticsDashboardModel(
        userSummary: UserSummaryModel(
          latestScore: 0,
          latestCompletion: 0,
          submissionReady: false,
          grade: '',
          totalSnapshots: 0,
        ),
        recentSnapshots: [],
        benchmarkingSummary: {},
        systemMetrics: {},
      ));
      when(mockRepository.getScoreSnapshots(
        snapshotType: null,
        submissionReady: null,
        limit: 50,
      )).thenAnswer((_) async => []);
      when(mockRepository.getTrendAnalysis(
        days: 30,
        metric: 'overall_score',
      )).thenAnswer((_) async => TrendAnalysisModel(
        trendDirection: 'stable',
        trendStrength: 'weak',
        slope: 0.0,
        rSquared: 0.0,
        absoluteChange: 0.0,
        percentageChange: 0.0,
        volatilityScore: 0.0,
        confidenceInterval: {},
        dataPoints: [],
        analysisStart: DateTime.now(),
        analysisEnd: DateTime.now(),
        dataPointsCount: 0,
      ));
      when(mockRepository.getBenchmarkingData()).thenAnswer((_) async => BenchmarkingDataModel(
        userId: '',
        currentScore: 0.0,
        percentileRank: 0.0,
        totalPeers: 0,
        groups: [],
        summary: {},
        peerComparisons: [],
      ));
      when(mockRepository.getCompletionStatistics(
        timePeriod: 30,
      )).thenAnswer((_) async => CompletionStatisticsModel(
        timePeriod: '30',
        totalUsers: 0,
        averageCompletion: 0.0,
        averageScore: 0.0,
        submissionReadyCount: 0,
        submissionReadyPercentage: 0.0,
        scoreDistribution: {},
        completionDistribution: {},
        sectionAverages: {},
        trends: [],
      ));

      provider.refreshAll();

      // Verify all methods are called
      verify(mockRepository.getDashboardData()).called(1);
      verify(mockRepository.getScoreSnapshots(
        snapshotType: null,
        submissionReady: null,
        limit: 50,
      )).called(1);
      verify(mockRepository.getTrendAnalysis(
        days: 30,
        metric: 'overall_score',
      )).called(1);
      verify(mockRepository.getBenchmarkingData()).called(1);
      verify(mockRepository.getCompletionStatistics(
        timePeriod: 30,
      )).called(1);
    });

    test('clearError should clear error message', () {
      provider.errorMessage = 'Test error';
      provider.clearError();
      expect(provider.errorMessage, null);
    });
  });
}