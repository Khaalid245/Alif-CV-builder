import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:educv/core/exceptions/app_exception.dart';
import 'package:educv/features/cv_intelligence/domain/cv_intelligence_repository.dart';
import 'package:educv/features/cv_intelligence/presentation/providers/cv_intelligence_provider.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

import 'cv_intelligence_provider_test.mocks.dart';

@GenerateMocks([CVIntelligenceRepository])
void main() {
  late MockCVIntelligenceRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockCVIntelligenceRepository();
    container = ProviderContainer(
      overrides: [
        cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AnalysisNotifier', () {
    test('should load latest analysis on initialization', () async {
      // Arrange
      final analysis = _createMockAnalysis();
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => analysis);

      // Act
      final notifier = container.read(analysisProvider.notifier);
      await container.pump();

      // Assert
      final state = container.read(analysisProvider);
      expect(state.analysis, equals(analysis));
      expect(state.isLoading, false);
      expect(state.error, isNull);
      verify(mockRepository.getLatestAnalysis()).called(1);
    });

    test('should handle error when loading latest analysis', () async {
      // Arrange
      final exception = AppException(message: 'Network error', statusCode: 500);
      when(mockRepository.getLatestAnalysis())
          .thenThrow(exception);

      // Act
      final notifier = container.read(analysisProvider.notifier);
      await container.pump();

      // Assert
      final state = container.read(analysisProvider);
      expect(state.analysis, isNull);
      expect(state.isLoading, false);
      expect(state.error, 'Network error');
    });

    test('should analyze CV successfully', () async {
      // Arrange
      final analysis = _createMockAnalysis();
      when(mockRepository.analyzeCV(options: anyNamed('options')))
          .thenAnswer((_) async => analysis);

      // Act
      final notifier = container.read(analysisProvider.notifier);
      await notifier.analyzeCV();

      // Assert
      final state = container.read(analysisProvider);
      expect(state.analysis, equals(analysis));
      expect(state.isLoading, false);
      expect(state.error, isNull);
      verify(mockRepository.analyzeCV(options: {})).called(1);
    });

    test('should handle error during CV analysis', () async {
      // Arrange
      final exception = AppException(message: 'Analysis failed', statusCode: 400);
      when(mockRepository.analyzeCV(options: anyNamed('options')))
          .thenThrow(exception);

      // Act
      final notifier = container.read(analysisProvider.notifier);
      
      // Assert
      expect(() => notifier.analyzeCV(), throwsA(isA<AppException>()));
      
      await container.pump();
      final state = container.read(analysisProvider);
      expect(state.isLoading, false);
      expect(state.error, 'Analysis failed');
    });

    test('should refresh analysis', () async {
      // Arrange
      final analysis = _createMockAnalysis();
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => analysis);

      // Act
      final notifier = container.read(analysisProvider.notifier);
      await notifier.refreshAnalysis();

      // Assert
      final state = container.read(analysisProvider);
      expect(state.analysis, equals(analysis));
      verify(mockRepository.getLatestAnalysis()).called(2); // Once on init, once on refresh
    });

    test('should clear error', () async {
      // Arrange
      final exception = AppException(message: 'Test error', statusCode: 500);
      when(mockRepository.getLatestAnalysis())
          .thenThrow(exception);

      final notifier = container.read(analysisProvider.notifier);
      await container.pump();

      // Verify error is set
      expect(container.read(analysisProvider).error, 'Test error');

      // Act
      notifier.clearError();

      // Assert
      final state = container.read(analysisProvider);
      expect(state.error, isNull);
    });
  });

  group('AnalysisHistoryNotifier', () {
    test('should load history on initialization', () async {
      // Arrange
      final history = _createMockAnalysisHistory();
      when(mockRepository.getAnalysisHistory(page: anyNamed('page')))
          .thenAnswer((_) async => history);

      // Act
      final notifier = container.read(analysisHistoryProvider.notifier);
      await container.pump();

      // Assert
      final state = container.read(analysisHistoryProvider);
      expect(state.history, equals(history));
      expect(state.isLoading, false);
      expect(state.error, isNull);
      verify(mockRepository.getAnalysisHistory(page: 1)).called(1);
    });

    test('should load more history when available', () async {
      // Arrange
      final initialHistory = AnalysisHistoryModel(
        analyses: [_createMockAnalysis()],
        totalCount: 2,
        hasNext: true,
        hasPrevious: false,
        currentPage: 1,
        totalPages: 2,
      );
      
      final nextPageHistory = AnalysisHistoryModel(
        analyses: [_createMockAnalysis(id: 'analysis-2')],
        totalCount: 2,
        hasNext: false,
        hasPrevious: true,
        currentPage: 2,
        totalPages: 2,
      );

      when(mockRepository.getAnalysisHistory(page: 1))
          .thenAnswer((_) async => initialHistory);
      when(mockRepository.getAnalysisHistory(page: 2))
          .thenAnswer((_) async => nextPageHistory);

      // Act
      final notifier = container.read(analysisHistoryProvider.notifier);
      await container.pump(); // Load initial
      await notifier.loadMoreHistory();

      // Assert
      final state = container.read(analysisHistoryProvider);
      expect(state.history!.analyses.length, 2);
      expect(state.currentPage, 2);
      expect(state.isLoadingMore, false);
      verify(mockRepository.getAnalysisHistory(page: 1)).called(1);
      verify(mockRepository.getAnalysisHistory(page: 2)).called(1);
    });

    test('should not load more when no next page', () async {
      // Arrange
      final history = AnalysisHistoryModel(
        analyses: [_createMockAnalysis()],
        totalCount: 1,
        hasNext: false,
        hasPrevious: false,
        currentPage: 1,
        totalPages: 1,
      );

      when(mockRepository.getAnalysisHistory(page: anyNamed('page')))
          .thenAnswer((_) async => history);

      // Act
      final notifier = container.read(analysisHistoryProvider.notifier);
      await container.pump();
      await notifier.loadMoreHistory();

      // Assert
      verify(mockRepository.getAnalysisHistory(page: 1)).called(1);
      verifyNever(mockRepository.getAnalysisHistory(page: 2));
    });

    test('should refresh history', () async {
      // Arrange
      final history = _createMockAnalysisHistory();
      when(mockRepository.getAnalysisHistory(page: anyNamed('page')))
          .thenAnswer((_) async => history);

      // Act
      final notifier = container.read(analysisHistoryProvider.notifier);
      await container.pump();
      await notifier.loadHistory(refresh: true);

      // Assert
      verify(mockRepository.getAnalysisHistory(page: 1)).called(2);
    });
  });

  group('RecommendationsNotifier', () {
    test('should load recommendations on initialization', () async {
      // Arrange
      final recommendations = [_createMockRecommendation()];
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => recommendations);

      // Act
      final notifier = container.read(recommendationsProvider.notifier);
      await container.pump();

      // Assert
      final state = container.read(recommendationsProvider);
      expect(state.recommendations, equals(recommendations));
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('should mark recommendation as implemented', () async {
      // Arrange
      final recommendation = _createMockRecommendation();
      final recommendations = [recommendation];
      
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => recommendations);
      
      when(mockRepository.markRecommendationImplemented(any))
          .thenAnswer((_) async {});

      // Act
      final notifier = container.read(recommendationsProvider.notifier);
      await container.pump();
      await notifier.markRecommendationImplemented(recommendation.id);

      // Assert
      final state = container.read(recommendationsProvider);
      final updatedRec = state.recommendations.first;
      expect(updatedRec.isImplemented, true);
      verify(mockRepository.markRecommendationImplemented(recommendation.id)).called(1);
    });

    test('should filter recommendations by category', () async {
      // Arrange
      final recommendations = [
        _createMockRecommendation(category: 'education'),
        _createMockRecommendation(category: 'experience', id: 'rec-2'),
      ];
      
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => recommendations);

      // Act
      final notifier = container.read(recommendationsProvider.notifier);
      await container.pump();
      notifier.setFilters(category: 'education');

      // Assert
      verify(mockRepository.getRecommendations(
        category: 'education',
        priority: null,
        includeImplemented: false,
      )).called(1);
    });

    test('should get high priority recommendations', () async {
      // Arrange
      final recommendations = [
        _createMockRecommendation(priority: 'high'),
        _createMockRecommendation(priority: 'low', id: 'rec-2'),
        _createMockRecommendation(priority: 'high', id: 'rec-3', isImplemented: true),
      ];
      
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => recommendations);

      // Act
      final notifier = container.read(recommendationsProvider.notifier);
      await container.pump();

      // Assert
      final state = container.read(recommendationsProvider);
      final highPriority = state.highPriorityRecommendations;
      expect(highPriority.length, 1); // Only non-implemented high priority
      expect(highPriority.first.priority, 'high');
      expect(highPriority.first.isImplemented, false);
    });

    test('should get available categories and priorities', () async {
      // Arrange
      final recommendations = [
        _createMockRecommendation(category: 'education', priority: 'high'),
        _createMockRecommendation(category: 'experience', priority: 'medium', id: 'rec-2'),
        _createMockRecommendation(category: 'education', priority: 'low', id: 'rec-3'),
      ];
      
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => recommendations);

      // Act
      final notifier = container.read(recommendationsProvider.notifier);
      await container.pump();

      // Assert
      final state = container.read(recommendationsProvider);
      expect(state.availableCategories, ['education', 'experience']);
      expect(state.availablePriorities, ['high', 'low', 'medium']);
    });

    test('should clear filters', () async {
      // Arrange
      final recommendations = [_createMockRecommendation()];
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => recommendations);

      // Act
      final notifier = container.read(recommendationsProvider.notifier);
      await container.pump();
      notifier.setFilters(category: 'education', priority: 'high');
      notifier.clearFilters();

      // Assert
      final state = container.read(recommendationsProvider);
      expect(state.selectedCategory, isNull);
      expect(state.selectedPriority, isNull);
      expect(state.includeImplemented, false);
    });
  });

  group('Provider integration', () {
    test('submissionReadinessProvider should return data', () async {
      // Arrange
      final readiness = _createMockSubmissionReadiness();
      when(mockRepository.getSubmissionReadiness())
          .thenAnswer((_) async => readiness);

      // Act
      final future = container.read(submissionReadinessProvider.future);
      final result = await future;

      // Assert
      expect(result, equals(readiness));
      verify(mockRepository.getSubmissionReadiness()).called(1);
    });

    test('benchmarkingDataProvider should return data with comparison group', () async {
      // Arrange
      final benchmarking = _createMockBenchmarkingData();
      const comparisonGroup = 'computer_science';
      when(mockRepository.getBenchmarkingData(comparisonGroup: comparisonGroup))
          .thenAnswer((_) async => benchmarking);

      // Act
      final future = container.read(benchmarkingDataProvider(comparisonGroup).future);
      final result = await future;

      // Assert
      expect(result, equals(benchmarking));
      verify(mockRepository.getBenchmarkingData(comparisonGroup: comparisonGroup)).called(1);
    });

    test('analysisConfigProvider should return configuration', () async {
      // Arrange
      final config = {'detailed_analysis': true, 'recommendation_limit': 10};
      when(mockRepository.getAnalysisConfig())
          .thenAnswer((_) async => config);

      // Act
      final future = container.read(analysisConfigProvider.future);
      final result = await future;

      // Assert
      expect(result, equals(config));
      verify(mockRepository.getAnalysisConfig()).called(1);
    });

    test('specificAnalysisProvider should return specific analysis', () async {
      // Arrange
      const analysisId = 'analysis-123';
      final analysis = _createMockAnalysis(id: analysisId);
      when(mockRepository.getAnalysisById(analysisId))
          .thenAnswer((_) async => analysis);

      // Act
      final future = container.read(specificAnalysisProvider(analysisId).future);
      final result = await future;

      // Assert
      expect(result, equals(analysis));
      expect(result.id, analysisId);
      verify(mockRepository.getAnalysisById(analysisId)).called(1);
    });
  });
}

// Helper methods to create mock objects
CVAnalysisModel _createMockAnalysis({String id = 'analysis-1'}) {
  return CVAnalysisModel(
    id: id,
    cvProfileId: 'cv-1',
    userId: 'user-1',
    overallScore: 85.0,
    sectionScores: {
      'education': SectionScoreModel(
        score: 90.0,
        maxScore: 100.0,
        weight: 1.0,
        status: 'excellent',
        strengths: ['Strong academic background'],
        weaknesses: [],
        suggestions: ['Add more details'],
        details: {},
      ),
    },
    recommendations: [_createMockRecommendation()],
    submissionReadiness: _createMockSubmissionReadiness(),
    metadata: {},
    analyzedAt: DateTime.parse('2024-01-01T00:00:00Z'),
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
  );
}

RecommendationModel _createMockRecommendation({
  String id = 'rec-1',
  String category = 'education',
  String priority = 'high',
  bool isImplemented = false,
}) {
  return RecommendationModel(
    id: id,
    category: category,
    priority: priority,
    title: 'Add GPA',
    description: 'Include your GPA in education section',
    actionText: 'Edit Education',
    metadata: {},
    isImplemented: isImplemented,
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
  );
}

SubmissionReadinessModel _createMockSubmissionReadiness() {
  return const SubmissionReadinessModel(
    isReady: true,
    readinessScore: 85.0,
    readyAspects: ['Education complete'],
    missingAspects: [],
    improvementAreas: ['Add more experience'],
    overallAssessment: 'Good to go',
    details: {},
  );
}

BenchmarkingDataModel _createMockBenchmarkingData() {
  return const BenchmarkingDataModel(
    percentileRank: 75.0,
    comparisonGroup: 'computer_science',
    sectionPercentiles: {
      'education': 80.0,
      'experience': 70.0,
    },
    insights: [],
    statistics: {},
  );
}

AnalysisHistoryModel _createMockAnalysisHistory() {
  return AnalysisHistoryModel(
    analyses: [_createMockAnalysis()],
    totalCount: 1,
    hasNext: false,
    hasPrevious: false,
    currentPage: 1,
    totalPages: 1,
  );
}