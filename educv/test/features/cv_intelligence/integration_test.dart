import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:educv/features/cv_intelligence/domain/cv_intelligence_repository.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';
import 'package:educv/features/cv_intelligence/presentation/providers/cv_intelligence_provider.dart';
import 'package:educv/features/cv_intelligence/presentation/screens/cv_intelligence_screen.dart';
import 'package:educv/features/cv_intelligence/presentation/widgets/cv_intelligence_summary_widget.dart';
import 'package:educv/core/exceptions/app_exception.dart';

import 'integration_test.mocks.dart';

@GenerateMocks([CVIntelligenceRepository])
void main() {
  group('CV Intelligence Integration Tests', () {
    late MockCVIntelligenceRepository mockRepository;

    setUp(() {
      mockRepository = MockCVIntelligenceRepository();
    });

    testWidgets('should display complete CV Intelligence screen with analysis', (tester) async {
      // Arrange
      final mockAnalysis = _createMockAnalysis();
      final mockRecommendations = [_createMockRecommendation()];
      final mockReadiness = _createMockSubmissionReadiness();
      final mockBenchmarking = _createMockBenchmarkingData();

      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => mockAnalysis);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => mockRecommendations);
      when(mockRepository.getSubmissionReadiness())
          .thenAnswer((_) async => mockReadiness);
      when(mockRepository.getBenchmarkingData(comparisonGroup: anyNamed('comparisonGroup')))
          .thenAnswer((_) async => mockBenchmarking);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert - Check main screen elements
      expect(find.text('CV Intelligence'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Sections'), findsOneWidget);
      expect(find.text('Recommendations'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // Check overall score display
      expect(find.text('Overall CV Score'), findsOneWidget);
      expect(find.text('86%'), findsOneWidget);

      // Check submission readiness
      expect(find.text('Submission Readiness'), findsOneWidget);

      // Check benchmarking
      expect(find.text('Benchmarking'), findsOneWidget);
      expect(find.text('75th'), findsOneWidget);
    });

    testWidgets('should handle empty analysis state', (tester) async {
      // Arrange
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => null);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No Analysis Yet'), findsOneWidget);
      expect(find.text('Get intelligent insights about your CV by running an analysis.'), findsOneWidget);
      expect(find.text('Analyze My CV'), findsOneWidget);
      expect(find.byIcon(LucideIcons.brain), findsAtLeastNWidgets(1));
    });

    testWidgets('should perform CV analysis when button is tapped', (tester) async {
      // Arrange
      final mockAnalysis = _createMockAnalysis();
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => null);
      when(mockRepository.analyzeCV(options: anyNamed('options')))
          .thenAnswer((_) async => mockAnalysis);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap analyze button
      await tester.tap(find.text('Analyze My CV'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.analyzeCV(options: anyNamed('options'))).called(1);
      expect(find.text('Overall CV Score'), findsOneWidget);
    });

    testWidgets('should display sections tab with section scores', (tester) async {
      // Arrange
      final mockAnalysis = _createMockAnalysis();
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => mockAnalysis);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap sections tab
      await tester.tap(find.text('Sections'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Section Scores'), findsOneWidget);
      expect(find.text('Education'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
    });

    testWidgets('should display recommendations tab with filters', (tester) async {
      // Arrange
      final mockRecommendations = [
        _createMockRecommendation(category: 'skills', priority: 'high'),
        _createMockRecommendation(category: 'education', priority: 'medium'),
      ];
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => null);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => mockRecommendations);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap recommendations tab
      await tester.tap(find.text('Recommendations'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Recommendations'), findsAtLeastNWidgets(1));
      expect(find.text('1 high priority items'), findsOneWidget);
      expect(find.text('Add Technical Skills'), findsNWidgets(2)); // One for each recommendation
    });

    testWidgets('should mark recommendation as implemented', (tester) async {
      // Arrange
      final mockRecommendations = [_createMockRecommendation()];
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => null);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => mockRecommendations);
      when(mockRepository.markRecommendationImplemented(any))
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to recommendations tab
      await tester.tap(find.text('Recommendations'));
      await tester.pumpAndSettle();

      // Tap mark as done button
      await tester.tap(find.text('Mark as Done'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.markRecommendationImplemented('rec-1')).called(1);
    });

    testWidgets('should display analysis history', (tester) async {
      // Arrange
      final mockHistory = AnalysisHistoryModel(
        analyses: [_createMockAnalysis()],
        totalCount: 1,
        hasNext: false,
        hasPrevious: false,
        currentPage: 1,
        totalPages: 1,
      );
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => null);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => []);
      when(mockRepository.getAnalysisHistory(
        page: anyNamed('page'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => mockHistory);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to history tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Analysis 1/1/2024'), findsOneWidget);
      expect(find.text('1 recommendations'), findsOneWidget);
    });

    testWidgets('should handle error states gracefully', (tester) async {
      // Arrange
      when(mockRepository.getLatestAnalysis())
          .thenThrow(AppException(message: 'Network error', statusCode: 500));
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenThrow(AppException(message: 'Failed to load recommendations', statusCode: 500));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Overview tab should show error
      expect(find.text('Network error'), findsOneWidget);

      // Navigate to recommendations tab
      await tester.tap(find.text('Recommendations'));
      await tester.pumpAndSettle();

      // Assert - Recommendations tab should show error
      expect(find.text('Failed to load recommendations'), findsOneWidget);
    });

    testWidgets('should refresh data when refresh button is tapped', (tester) async {
      // Arrange
      final mockAnalysis = _createMockAnalysis();
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => mockAnalysis);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap refresh button
      await tester.tap(find.byIcon(LucideIcons.refreshCw));
      await tester.pumpAndSettle();

      // Assert - Should call repository methods again
      verify(mockRepository.getLatestAnalysis()).called(2); // Once for init, once for refresh
    });

    testWidgets('CV Intelligence Summary Widget should integrate properly', (tester) async {
      // Arrange
      final mockAnalysis = _createMockAnalysis();
      final mockReadiness = _createMockSubmissionReadiness();
      
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async => mockAnalysis);
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => [_createMockRecommendation(priority: 'high')]);
      when(mockRepository.getSubmissionReadiness())
          .thenAnswer((_) async => mockReadiness);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CVIntelligenceSummaryWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('CV Intelligence'), findsOneWidget);
      expect(find.text('AI-powered insights for your CV'), findsOneWidget);
      expect(find.text('Overall Score'), findsOneWidget);
      expect(find.text('86%'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('1 high priority recommendations'), findsOneWidget);
      expect(find.text('Re-analyze'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('should handle loading states correctly', (tester) async {
      // Arrange - Create a completer to control when the future completes
      when(mockRepository.getLatestAnalysis())
          .thenAnswer((_) async {
        // Simulate a delay
        await Future.delayed(Duration(seconds: 1));
        return _createMockAnalysis();
      });
      when(mockRepository.getRecommendations(
        category: anyNamed('category'),
        priority: anyNamed('priority'),
        includeImplemented: anyNamed('includeImplemented'),
      )).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cvIntelligenceRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: CVIntelligenceScreen(),
          ),
        ),
      );

      // Assert - Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the future to complete
      await tester.pumpAndSettle();

      // Assert - Should show content after loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Overall CV Score'), findsOneWidget);
    });
  });
}

// Helper functions to create mock data
CVAnalysisModel _createMockAnalysis() {
  return CVAnalysisModel(
    id: 'analysis-123',
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
  String? category,
  String? priority,
}) {
  return RecommendationModel(
    id: 'rec-1',
    category: category ?? 'skills',
    priority: priority ?? 'high',
    title: 'Add Technical Skills',
    description: 'Consider adding more technical skills to your CV',
    actionText: 'Add Skills',
    actionUrl: 'https://example.com',
    metadata: {},
    isImplemented: false,
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