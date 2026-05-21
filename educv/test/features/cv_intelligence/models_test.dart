import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

void main() {
  group('CV Intelligence Models Tests', () {
    group('CVAnalysisModel', () {
      test('should create from valid JSON', () {
        // Arrange
        final json = {
          'id': 'analysis-123',
          'cv_profile': 'cv-456',
          'user': 'user-789',
          'overall_score': 85.5,
          'section_scores': {
            'education': {
              'score': 90.0,
              'max_score': 100.0,
              'weight': 1.0,
              'status': 'excellent',
              'strengths': ['Strong academic background'],
              'weaknesses': [],
              'suggestions': ['Add more certifications'],
              'details': {}
            }
          },
          'recommendations': [
            {
              'id': 'rec-1',
              'category': 'education',
              'priority': 'high',
              'title': 'Add Certifications',
              'description': 'Consider adding relevant certifications',
              'action_text': 'Add Certification',
              'action_url': null,
              'metadata': {},
              'is_implemented': false,
              'created_at': '2024-01-01T00:00:00Z'
            }
          ],
          'submission_readiness': {
            'is_ready': true,
            'readiness_score': 85.0,
            'ready_aspects': ['Complete profile'],
            'missing_aspects': [],
            'improvement_areas': ['Add more skills'],
            'overall_assessment': 'Good to go',
            'details': {}
          },
          'benchmarking_data': null,
          'metadata': {'version': '1.0'},
          'analyzed_at': '2024-01-01T00:00:00Z',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z'
        };

        // Act
        final analysis = CVAnalysisModel.fromJson(json);

        // Assert
        expect(analysis.id, equals('analysis-123'));
        expect(analysis.cvProfileId, equals('cv-456'));
        expect(analysis.userId, equals('user-789'));
        expect(analysis.overallScore, equals(85.5));
        expect(analysis.sectionScores.length, equals(1));
        expect(analysis.recommendations.length, equals(1));
        expect(analysis.submissionReadiness.isReady, isTrue);
        expect(analysis.benchmarkingData, isNull);
      });

      test('should handle invalid JSON gracefully', () {
        // Arrange
        final invalidJson = {
          'invalid_field': 'value'
        };

        // Act & Assert
        expect(
          () => CVAnalysisModel.fromJson(invalidJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('should convert to JSON correctly', () {
        // Arrange
        final analysis = CVAnalysisModel(
          id: 'test-id',
          cvProfileId: 'cv-id',
          userId: 'user-id',
          overallScore: 75.0,
          sectionScores: {},
          recommendations: [],
          submissionReadiness: SubmissionReadinessModel(
            isReady: false,
            readinessScore: 60.0,
            readyAspects: [],
            missingAspects: ['Skills'],
            improvementAreas: ['Add more experience'],
            overallAssessment: 'Needs improvement',
            details: {},
          ),
          metadata: {},
          analyzedAt: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        // Act
        final json = analysis.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['overall_score'], equals(75.0));
        expect(json['submission_readiness']['is_ready'], isFalse);
      });
    });

    group('SectionScoreModel', () {
      test('should calculate percentage correctly', () {
        // Arrange
        final sectionScore = SectionScoreModel(
          score: 80.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'good',
          strengths: ['Strong content'],
          weaknesses: ['Formatting issues'],
          suggestions: ['Improve layout'],
          details: {},
        );

        // Act & Assert
        expect(sectionScore.percentage, equals(80.0));
        expect(sectionScore.isGood, isTrue);
        expect(sectionScore.isExcellent, isFalse);
        expect(sectionScore.isPoor, isFalse);
      });

      test('should handle zero max score', () {
        // Arrange
        final sectionScore = SectionScoreModel(
          score: 50.0,
          maxScore: 0.0,
          weight: 1.0,
          status: 'unknown',
          strengths: [],
          weaknesses: [],
          suggestions: [],
          details: {},
        );

        // Act & Assert
        expect(sectionScore.percentage, equals(0.0));
      });

      test('should categorize performance levels correctly', () {
        // Test excellent
        final excellent = SectionScoreModel(
          score: 95.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'excellent',
          strengths: [],
          weaknesses: [],
          suggestions: [],
          details: {},
        );
        expect(excellent.isExcellent, isTrue);

        // Test good
        final good = SectionScoreModel(
          score: 75.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'good',
          strengths: [],
          weaknesses: [],
          suggestions: [],
          details: {},
        );
        expect(good.isGood, isTrue);

        // Test average
        final average = SectionScoreModel(
          score: 55.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'average',
          strengths: [],
          weaknesses: [],
          suggestions: [],
          details: {},
        );
        expect(average.isAverage, isTrue);

        // Test poor
        final poor = SectionScoreModel(
          score: 30.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'poor',
          strengths: [],
          weaknesses: [],
          suggestions: [],
          details: {},
        );
        expect(poor.isPoor, isTrue);
      });
    });

    group('RecommendationModel', () {
      test('should identify priority levels correctly', () {
        // High priority
        final highPriority = RecommendationModel(
          id: 'rec-1',
          category: 'skills',
          priority: 'high',
          title: 'Add Skills',
          description: 'Add more technical skills',
          actionText: 'Add Skills',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );
        expect(highPriority.isHighPriority, isTrue);
        expect(highPriority.isMediumPriority, isFalse);
        expect(highPriority.isLowPriority, isFalse);

        // Medium priority
        final mediumPriority = RecommendationModel(
          id: 'rec-2',
          category: 'experience',
          priority: 'medium',
          title: 'Update Experience',
          description: 'Update work experience',
          actionText: 'Update',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );
        expect(mediumPriority.isMediumPriority, isTrue);

        // Low priority
        final lowPriority = RecommendationModel(
          id: 'rec-3',
          category: 'formatting',
          priority: 'low',
          title: 'Format Improvement',
          description: 'Minor formatting improvements',
          actionText: 'Improve',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );
        expect(lowPriority.isLowPriority, isTrue);
      });

      test('should handle copyWith correctly', () {
        // Arrange
        final original = RecommendationModel(
          id: 'rec-1',
          category: 'skills',
          priority: 'high',
          title: 'Original Title',
          description: 'Original description',
          actionText: 'Original Action',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );

        // Act
        final updated = original.copyWith(
          title: 'Updated Title',
          isImplemented: true,
        );

        // Assert
        expect(updated.title, equals('Updated Title'));
        expect(updated.isImplemented, isTrue);
        expect(updated.id, equals(original.id)); // Unchanged
        expect(updated.category, equals(original.category)); // Unchanged
      });
    });

    group('SubmissionReadinessModel', () {
      test('should determine readiness level correctly', () {
        // Excellent
        final excellent = SubmissionReadinessModel(
          isReady: true,
          readinessScore: 95.0,
          readyAspects: ['All sections complete'],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: 'Excellent',
          details: {},
        );
        expect(excellent.readinessLevel, equals('Excellent'));

        // Good
        final good = SubmissionReadinessModel(
          isReady: true,
          readinessScore: 80.0,
          readyAspects: ['Most sections complete'],
          missingAspects: [],
          improvementAreas: ['Minor improvements'],
          overallAssessment: 'Good',
          details: {},
        );
        expect(good.readinessLevel, equals('Good'));

        // Fair
        final fair = SubmissionReadinessModel(
          isReady: false,
          readinessScore: 65.0,
          readyAspects: ['Basic info complete'],
          missingAspects: ['Skills section'],
          improvementAreas: ['Add more content'],
          overallAssessment: 'Fair',
          details: {},
        );
        expect(fair.readinessLevel, equals('Fair'));

        // Needs Improvement
        final needsWork = SubmissionReadinessModel(
          isReady: false,
          readinessScore: 40.0,
          readyAspects: [],
          missingAspects: ['Multiple sections'],
          improvementAreas: ['Complete profile'],
          overallAssessment: 'Needs work',
          details: {},
        );
        expect(needsWork.readinessLevel, equals('Needs Improvement'));
      });
    });

    group('BenchmarkingDataModel', () {
      test('should determine performance level correctly', () {
        // Top 10%
        final top10 = BenchmarkingDataModel(
          percentileRank: 95.0,
          comparisonGroup: 'Computer Science Students',
          sectionPercentiles: {},
          insights: [],
          statistics: {},
        );
        expect(top10.performanceLevel, equals('Top 10%'));

        // Top 25%
        final top25 = BenchmarkingDataModel(
          percentileRank: 80.0,
          comparisonGroup: 'Engineering Students',
          sectionPercentiles: {},
          insights: [],
          statistics: {},
        );
        expect(top25.performanceLevel, equals('Top 25%'));

        // Above Average
        final aboveAverage = BenchmarkingDataModel(
          percentileRank: 60.0,
          comparisonGroup: 'All Students',
          sectionPercentiles: {},
          insights: [],
          statistics: {},
        );
        expect(aboveAverage.performanceLevel, equals('Above Average'));

        // Below Average
        final belowAverage = BenchmarkingDataModel(
          percentileRank: 30.0,
          comparisonGroup: 'All Students',
          sectionPercentiles: {},
          insights: [],
          statistics: {},
        );
        expect(belowAverage.performanceLevel, equals('Below Average'));

        // Bottom 25%
        final bottom25 = BenchmarkingDataModel(
          percentileRank: 15.0,
          comparisonGroup: 'All Students',
          sectionPercentiles: {},
          insights: [],
          statistics: {},
        );
        expect(bottom25.performanceLevel, equals('Bottom 25%'));
      });
    });

    group('BenchmarkInsightModel', () {
      test('should identify insight severity correctly', () {
        // Positive
        final positive = BenchmarkInsightModel(
          type: 'performance',
          message: 'Great job!',
          severity: 'positive',
          data: {},
        );
        expect(positive.isPositive, isTrue);
        expect(positive.isWarning, isFalse);
        expect(positive.isNegative, isFalse);

        // Warning
        final warning = BenchmarkInsightModel(
          type: 'improvement',
          message: 'Could be better',
          severity: 'warning',
          data: {},
        );
        expect(warning.isWarning, isTrue);

        // Negative
        final negative = BenchmarkInsightModel(
          type: 'issue',
          message: 'Needs attention',
          severity: 'negative',
          data: {},
        );
        expect(negative.isNegative, isTrue);
      });
    });

    group('AnalysisHistoryModel', () {
      test('should parse paginated results correctly', () {
        // Arrange
        final json = {
          'results': [
            {
              'id': 'analysis-1',
              'cv_profile': 'cv-1',
              'user': 'user-1',
              'overall_score': 80.0,
              'section_scores': {},
              'recommendations': [],
              'submission_readiness': {
                'is_ready': false,
                'readiness_score': 70.0,
                'ready_aspects': [],
                'missing_aspects': [],
                'improvement_areas': [],
                'overall_assessment': '',
                'details': {}
              },
              'metadata': {},
              'analyzed_at': '2024-01-01T00:00:00Z',
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z'
            }
          ],
          'count': 10,
          'next': 'http://example.com/page2',
          'previous': null,
          'current_page': 1,
          'total_pages': 2
        };

        // Act
        final history = AnalysisHistoryModel.fromJson(json);

        // Assert
        expect(history.analyses.length, equals(1));
        expect(history.totalCount, equals(10));
        expect(history.hasNext, isTrue);
        expect(history.hasPrevious, isFalse);
        expect(history.currentPage, equals(1));
        expect(history.totalPages, equals(2));
      });
    });
  });
}