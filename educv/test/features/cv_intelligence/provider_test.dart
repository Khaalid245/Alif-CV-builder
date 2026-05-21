import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:educv/features/cv_intelligence/domain/cv_intelligence_repository.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';
import 'package:educv/features/cv_intelligence/presentation/providers/cv_intelligence_provider.dart';
import 'package:educv/core/exceptions/app_exception.dart';

import 'provider_test.mocks.dart';

@GenerateMocks([CVIntelligenceRepository])
void main() {
  group('CV Intelligence Provider Tests', () {
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
        final mockAnalysis = _createMockAnalysis();
        when(mockRepository.getLatestAnalysis())
            .thenAnswer((_) async => mockAnalysis);

        // Act
        final notifier = container.read(analysisProvider.notifier);
        
        // Wait for initialization
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(analysisProvider);
        expect(state.analysis, equals(mockAnalysis));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        verify(mockRepository.getLatestAnalysis()).called(1);
      });

      test('should handle no analysis available', () async {
        // Arrange
        when(mockRepository.getLatestAnalysis())
            .thenAnswer((_) async => null);

        // Act
        final notifier = container.read(analysisProvider.notifier);
        
        // Wait for initialization
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(analysisProvider);
        expect(state.analysis, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('should handle loading error', () async {
        // Arrange
        when(mockRepository.getLatestAnalysis())
            .thenThrow(AppException(message: 'Network error', statusCode: 500));

        // Act
        final notifier = container.read(analysisProvider.notifier);
        
        // Wait for initialization
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(analysisProvider);
        expect(state.analysis, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, equals('Network error'));
      });

      test('should analyze CV successfully', () async {
        // Arrange
        final mockAnalysis = _createMockAnalysis();
        when(mockRepository.getLatestAnalysis())
            .thenAnswer((_) async => null);
        when(mockRepository.analyzeCV(options: anyNamed('options')))
            .thenAnswer((_) async => mockAnalysis);

        final notifier = container.read(analysisProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        await notifier.analyzeCV(options: {'detailed': true});

        // Assert
        final state = container.read(analysisProvider);
        expect(state.analysis, equals(mockAnalysis));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        verify(mockRepository.analyzeCV(options: {'detailed': true})).called(1);
      });

      test('should handle analyze CV error', () async {
        // Arrange
        when(mockRepository.getLatestAnalysis())
            .thenAnswer((_) async => null);
        when(mockRepository.analyzeCV(options: anyNamed('options')))
            .thenThrow(AppException(message: 'Analysis failed', statusCode: 400));

        final notifier = container.read(analysisProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act & Assert
        expect(
          () => notifier.analyzeCV(),
          throwsA(isA<AppException>()),
        );

        final state = container.read(analysisProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, equals('Analysis failed'));
      });

      test('should refresh analysis', () async {
        // Arrange
        final mockAnalysis = _createMockAnalysis();
        when(mockRepository.getLatestAnalysis())
            .thenAnswer((_) async => mockAnalysis);

        final notifier = container.read(analysisProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        await notifier.refreshAnalysis();

        // Assert
        verify(mockRepository.getLatestAnalysis()).called(2); // Once for init, once for refresh
      });

      test('should clear error', () async {
        // Arrange
        when(mockRepository.getLatestAnalysis())
            .thenThrow(AppException(message: 'Error', statusCode: 500));

        final notifier = container.read(analysisProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

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
        final mockHistory = _createMockAnalysisHistory();
        when(mockRepository.getAnalysisHistory(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => mockHistory);

        // Act
        final notifier = container.read(analysisHistoryProvider.notifier);
        
        // Wait for initialization
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(analysisHistoryProvider);
        expect(state.history, equals(mockHistory));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        verify(mockRepository.getAnalysisHistory(page: 1, pageSize: 10)).called(1);
      });

      test('should load more history', () async {
        // Arrange
        final firstBatch = _createMockAnalysisHistory();
        final secondBatch = AnalysisHistoryModel(
          analyses: [_createMockAnalysis()],
          totalCount: 2,
          hasNext: false,
          hasPrevious: true,
          currentPage: 2,
          totalPages: 2,
        );

        when(mockRepository.getAnalysisHistory(
          page: 1,
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => firstBatch);

        when(mockRepository.getAnalysisHistory(
          page: 2,
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => secondBatch);

        final notifier = container.read(analysisHistoryProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        await notifier.loadMoreHistory();

        // Assert
        final state = container.read(analysisHistoryProvider);
        expect(state.history!.analyses.length, equals(2));
        expect(state.currentPage, equals(2));
        expect(state.isLoadingMore, isFalse);
      });

      test('should not load more when already loading', () async {
        // Arrange
        final mockHistory = _createMockAnalysisHistory();
        when(mockRepository.getAnalysisHistory(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => mockHistory);

        final notifier = container.read(analysisHistoryProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act - Try to load more while already loading
        final future1 = notifier.loadMoreHistory();
        final future2 = notifier.loadMoreHistory();

        await Future.wait([future1, future2]);

        // Assert - Should only call API once for load more
        verify(mockRepository.getAnalysisHistory(page: 2, pageSize: 10)).called(1);
      });

      test('should refresh history', () async {
        // Arrange
        final mockHistory = _createMockAnalysisHistory();
        when(mockRepository.getAnalysisHistory(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => mockHistory);

        final notifier = container.read(analysisHistoryProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        await notifier.loadHistory(refresh: true);

        // Assert
        verify(mockRepository.getAnalysisHistory(page: 1, pageSize: 10)).called(2);
      });
    });

    group('RecommendationsNotifier', () {
      test('should load recommendations on initialization', () async {
        // Arrange
        final mockRecommendations = [_createMockRecommendation()];
        when(mockRepository.getRecommendations(
          category: anyNamed('category'),
          priority: anyNamed('priority'),
          includeImplemented: anyNamed('includeImplemented'),
        )).thenAnswer((_) async => mockRecommendations);

        // Act
        final notifier = container.read(recommendationsProvider.notifier);
        
        // Wait for initialization
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(recommendationsProvider);
        expect(state.recommendations, equals(mockRecommendations));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('should mark recommendation as implemented', () async {
        // Arrange
        final mockRecommendations = [
          _createMockRecommendation(id: 'rec-1', isImplemented: false),
          _createMockRecommendation(id: 'rec-2', isImplemented: false),
        ];
        
        when(mockRepository.getRecommendations(
          category: anyNamed('category'),
          priority: anyNamed('priority'),
          includeImplemented: anyNamed('includeImplemented'),
        )).thenAnswer((_) async => mockRecommendations);

        when(mockRepository.markRecommendationImplemented('rec-1'))
            .thenAnswer((_) async {});

        final notifier = container.read(recommendationsProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        await notifier.markRecommendationImplemented('rec-1');

        // Assert
        final state = container.read(recommendationsProvider);
        final updatedRec = state.recommendations.firstWhere((r) => r.id == 'rec-1');
        expect(updatedRec.isImplemented, isTrue);
        
        final unchangedRec = state.recommendations.firstWhere((r) => r.id == 'rec-2');
        expect(unchangedRec.isImplemented, isFalse);

        verify(mockRepository.markRecommendationImplemented('rec-1')).called(1);
      });

      test('should filter recommendations correctly', () async {
        // Arrange
        final mockRecommendations = [
          _createMockRecommendation(category: 'skills', priority: 'high', isImplemented: false),
          _createMockRecommendation(category: 'education', priority: 'medium', isImplemented: false),
          _createMockRecommendation(category: 'skills', priority: 'low', isImplemented: true),
        ];
        
        when(mockRepository.getRecommendations(
          category: anyNamed('category'),
          priority: anyNamed('priority'),
          includeImplemented: anyNamed('includeImplemented'),
        )).thenAnswer((_) async => mockRecommendations);

        final notifier = container.read(recommendationsProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        notifier.setFilters(category: 'skills', includeImplemented: false);
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(recommendationsProvider);
        expect(state.selectedCategory, equals('skills'));
        expect(state.includeImplemented, isFalse);
        
        final filtered = state.filteredRecommendations;
        expect(filtered.length, equals(1)); // Only non-implemented skills recommendations
        expect(filtered.first.category, equals('skills'));
        expect(filtered.first.isImplemented, isFalse);
      });

      test('should get high priority recommendations', () async {
        // Arrange
        final mockRecommendations = [
          _createMockRecommendation(priority: 'high', isImplemented: false),
          _createMockRecommendation(priority: 'medium', isImplemented: false),
          _createMockRecommendation(priority: 'high', isImplemented: true),
        ];
        
        when(mockRepository.getRecommendations(
          category: anyNamed('category'),
          priority: anyNamed('priority'),
          includeImplemented: anyNamed('includeImplemented'),
        )).thenAnswer((_) async => mockRecommendations);

        final notifier = container.read(recommendationsProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        final state = container.read(recommendationsProvider);

        // Assert
        final highPriority = state.highPriorityRecommendations;
        expect(highPriority.length, equals(1)); // Only non-implemented high priority
        expect(highPriority.first.priority, equals('high'));
        expect(highPriority.first.isImplemented, isFalse);
      });

      test('should get available categories and priorities', () async {
        // Arrange
        final mockRecommendations = [
          _createMockRecommendation(category: 'skills', priority: 'high'),
          _createMockRecommendation(category: 'education', priority: 'medium'),
          _createMockRecommendation(category: 'skills', priority: 'low'),
        ];
        
        when(mockRepository.getRecommendations(
          category: anyNamed('category'),
          priority: anyNamed('priority'),
          includeImplemented: anyNamed('includeImplemented'),
        )).thenAnswer((_) async => mockRecommendations);

        final notifier = container.read(recommendationsProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Act
        final state = container.read(recommendationsProvider);

        // Assert
        expect(state.availableCategories, containsAll(['education', 'skills']));
        expect(state.availablePriorities, containsAll(['high', 'low', 'medium']));
      });

      test('should clear filters', () async {
        // Arrange
        final mockRecommendations = [_createMockRecommendation()];
        when(mockRepository.getRecommendations(
          category: anyNamed('category'),
          priority: anyNamed('priority'),
          includeImplemented: anyNamed('includeImplemented'),
        )).thenAnswer((_) async => mockRecommendations);

        final notifier = container.read(recommendationsProvider.notifier);
        await Future.delayed(Duration.zero); // Wait for initialization

        // Set some filters first
        notifier.setFilters(category: 'skills', priority: 'high');
        await Future.delayed(Duration.zero);

        // Act
        notifier.clearFilters();
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(recommendationsProvider);
        expect(state.selectedCategory, isNull);
        expect(state.selectedPriority, isNull);
        expect(state.includeImplemented, isFalse);
      });
    });

    group('FutureProviders', () {
      test('submissionReadinessProvider should return readiness data', () async {
        // Arrange
        final mockReadiness = _createMockSubmissionReadiness();
        when(mockRepository.getSubmissionReadiness())
            .thenAnswer((_) async => mockReadiness);

        // Act
        final readinessAsync = container.read(submissionReadinessProvider);

        // Assert
        await expectLater(readinessAsync, completion(equals(mockReadiness)));
        verify(mockRepository.getSubmissionReadiness()).called(1);
      });

      test('benchmarkingDataProvider should return benchmarking data', () async {
        // Arrange
        final mockBenchmarking = _createMockBenchmarkingData();
        when(mockRepository.getBenchmarkingData(comparisonGroup: 'computer_science'))
            .thenAnswer((_) async => mockBenchmarking);

        // Act
        final benchmarkingAsync = container.read(
          benchmarkingDataProvider('computer_science'),
        );

        // Assert
        await expectLater(benchmarkingAsync, completion(equals(mockBenchmarking)));
        verify(mockRepository.getBenchmarkingData(comparisonGroup: 'computer_science')).called(1);
      });

      test('analysisConfigProvider should return config data', () async {
        // Arrange
        final mockConfig = {'analysis_depth': 'detailed'};
        when(mockRepository.getAnalysisConfig())
            .thenAnswer((_) async => mockConfig);

        // Act
        final configAsync = container.read(analysisConfigProvider);

        // Assert
        await expectLater(configAsync, completion(equals(mockConfig)));
        verify(mockRepository.getAnalysisConfig()).called(1);
      });

      test('specificAnalysisProvider should return specific analysis', () async {
        // Arrange
        final mockAnalysis = _createMockAnalysis();
        when(mockRepository.getAnalysisById('analysis-123'))
            .thenAnswer((_) async => mockAnalysis);

        // Act
        final analysisAsync = container.read(
          specificAnalysisProvider('analysis-123'),
        );

        // Assert
        await expectLater(analysisAsync, completion(equals(mockAnalysis)));
        verify(mockRepository.getAnalysisById('analysis-123')).called(1);
      });
    });
  });
}

// Helper functions to create mock data
CVAnalysisModel _createMockAnalysis({String? id}) {
  return CVAnalysisModel(
    id: id ?? 'analysis-123',
    cvProfileId: 'cv-456',
    userId: 'user-789',
    overallScore: 85.5,
    sectionScores: {
      'education': SectionScoreModel(
        score: 90.0,
        maxScore: 100.0,
        weight: 1.0,
        status: 'excellent',
        strengths: ['Strong academic background'],
        weaknesses: [],
        suggestions: ['Add more certifications'],
        details: {},
      ),
    },
    recommendations: [_createMockRecommendation()],
    submissionReadiness: _createMockSubmissionReadiness(),
    metadata: {},
    analyzedAt: DateTime(2024, 1, 1),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

RecommendationModel _createMockRecommendation({
  String? id,
  String? category,
  String? priority,
  bool? isImplemented,
}) {
  return RecommendationModel(
    id: id ?? 'rec-1',
    category: category ?? 'education',
    priority: priority ?? 'high',
    title: 'Add Certifications',
    description: 'Consider adding relevant certifications',
    actionText: 'Add Certification',
    metadata: {},
    isImplemented: isImplemented ?? false,
    createdAt: DateTime(2024, 1, 1),
  );
}

SubmissionReadinessModel _createMockSubmissionReadiness() {
  return SubmissionReadinessModel(
    isReady: true,
    readinessScore: 85.0,
    readyAspects: ['Complete profile'],
    missingAspects: [],
    improvementAreas: ['Add more skills'],
    overallAssessment: 'Good to go',
    details: {},
  );
}

BenchmarkingDataModel _createMockBenchmarkingData() {
  return BenchmarkingDataModel(
    percentileRank: 75.0,
    comparisonGroup: 'Computer Science Students',
    sectionPercentiles: {'education': 80.0, 'skills': 70.0},
    insights: [],
    statistics: {},
  );
}

AnalysisHistoryModel _createMockAnalysisHistory() {
  return AnalysisHistoryModel(
    analyses: [_createMockAnalysis()],
    totalCount: 1,
    hasNext: true,
    hasPrevious: false,
    currentPage: 1,
    totalPages: 2,
  );
}