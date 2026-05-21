import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

void main() {
  group('CVAnalysisModel', () {
    test('should create model from valid JSON', () {
      final json = {
        'id': 'test-id',
        'cv_profile': 'cv-id',
        'user': 'user-id',
        'overall_score': 85.5,
        'section_scores': {
          'education': {
            'score': 90.0,
            'max_score': 100.0,
            'weight': 1.0,
            'status': 'excellent',
            'strengths': ['Strong academic background'],
            'weaknesses': [],
            'suggestions': ['Add more details'],
            'details': {},
          },
        },
        'recommendations': [
          {
            'id': 'rec-1',
            'category': 'education',
            'priority': 'high',
            'title': 'Add GPA',
            'description': 'Include your GPA',
            'action_text': 'Edit Education',
            'metadata': {},
            'is_implemented': false,
            'created_at': '2024-01-01T00:00:00Z',
          },
        ],
        'submission_readiness': {
          'is_ready': true,
          'readiness_score': 85.0,
          'ready_aspects': ['Education complete'],
          'missing_aspects': [],
          'improvement_areas': ['Add more experience'],
          'overall_assessment': 'Good to go',
          'details': {},
        },
        'metadata': {'version': '1.0'},
        'analyzed_at': '2024-01-01T00:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final model = CVAnalysisModel.fromJson(json);

      expect(model.id, 'test-id');
      expect(model.cvProfileId, 'cv-id');
      expect(model.userId, 'user-id');
      expect(model.overallScore, 85.5);
      expect(model.sectionScores.length, 1);
      expect(model.recommendations.length, 1);
      expect(model.submissionReadiness.isReady, true);
    });

    test('should handle missing fields gracefully', () {
      final json = <String, dynamic>{};

      final model = CVAnalysisModel.fromJson(json);

      expect(model.id, '');
      expect(model.overallScore, 0.0);
      expect(model.sectionScores.isEmpty, true);
      expect(model.recommendations.isEmpty, true);
    });

    test('should throw FormatException for invalid data', () {
      final json = {
        'section_scores': 'invalid_data', // Should be a map
      };

      expect(() => CVAnalysisModel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('should convert to JSON correctly', () {
      final model = CVAnalysisModel(
        id: 'test-id',
        cvProfileId: 'cv-id',
        userId: 'user-id',
        overallScore: 85.5,
        sectionScores: {},
        recommendations: [],
        submissionReadiness: const SubmissionReadinessModel(
          isReady: true,
          readinessScore: 85.0,
          readyAspects: [],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: '',
          details: {},
        ),
        metadata: {},
        analyzedAt: DateTime.parse('2024-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      final json = model.toJson();

      expect(json['id'], 'test-id');
      expect(json['overall_score'], 85.5);
      expect(json['submission_readiness']['is_ready'], true);
    });
  });

  group('SectionScoreModel', () {
    test('should calculate percentage correctly', () {
      final model = SectionScoreModel(
        score: 85.0,
        maxScore: 100.0,
        weight: 1.0,
        status: 'good',
        strengths: [],
        weaknesses: [],
        suggestions: [],
        details: {},
      );

      expect(model.percentage, 85.0);
      expect(model.isGood, true);
      expect(model.isExcellent, false);
    });

    test('should handle zero max score', () {
      final model = SectionScoreModel(
        score: 85.0,
        maxScore: 0.0,
        weight: 1.0,
        status: 'good',
        strengths: [],
        weaknesses: [],
        suggestions: [],
        details: {},
      );

      expect(model.percentage, 0.0);
    });

    test('should categorize performance levels correctly', () {
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

      final poor = SectionScoreModel(
        score: 35.0,
        maxScore: 100.0,
        weight: 1.0,
        status: 'poor',
        strengths: [],
        weaknesses: [],
        suggestions: [],
        details: {},
      );

      expect(excellent.isExcellent, true);
      expect(good.isGood, true);
      expect(average.isAverage, true);
      expect(poor.isPoor, true);
    });
  });

  group('RecommendationModel', () {
    test('should identify priority levels correctly', () {
      final high = RecommendationModel(
        id: '1',
        category: 'test',
        priority: 'high',
        title: 'Test',
        description: 'Test',
        actionText: 'Test',
        metadata: {},
        isImplemented: false,
        createdAt: DateTime.now(),
      );

      final medium = RecommendationModel(
        id: '2',
        category: 'test',
        priority: 'medium',
        title: 'Test',
        description: 'Test',
        actionText: 'Test',
        metadata: {},
        isImplemented: false,
        createdAt: DateTime.now(),
      );

      final low = RecommendationModel(
        id: '3',
        category: 'test',
        priority: 'low',
        title: 'Test',
        description: 'Test',
        actionText: 'Test',
        metadata: {},
        isImplemented: false,
        createdAt: DateTime.now(),
      );

      expect(high.isHighPriority, true);
      expect(medium.isMediumPriority, true);
      expect(low.isLowPriority, true);
    });

    test('should handle case insensitive priority', () {
      final model = RecommendationModel(
        id: '1',
        category: 'test',
        priority: 'HIGH',
        title: 'Test',
        description: 'Test',
        actionText: 'Test',
        metadata: {},
        isImplemented: false,
        createdAt: DateTime.now(),
      );

      expect(model.isHighPriority, true);
    });
  });

  group('SubmissionReadinessModel', () {
    test('should determine readiness level correctly', () {
      final excellent = SubmissionReadinessModel(
        isReady: true,
        readinessScore: 95.0,
        readyAspects: [],
        missingAspects: [],
        improvementAreas: [],
        overallAssessment: '',
        details: {},
      );

      final good = SubmissionReadinessModel(
        isReady: true,
        readinessScore: 80.0,
        readyAspects: [],
        missingAspects: [],
        improvementAreas: [],
        overallAssessment: '',
        details: {},
      );

      final fair = SubmissionReadinessModel(
        isReady: false,
        readinessScore: 65.0,
        readyAspects: [],
        missingAspects: [],
        improvementAreas: [],
        overallAssessment: '',
        details: {},
      );

      final needsWork = SubmissionReadinessModel(
        isReady: false,
        readinessScore: 45.0,
        readyAspects: [],
        missingAspects: [],
        improvementAreas: [],
        overallAssessment: '',
        details: {},
      );

      expect(excellent.readinessLevel, 'Excellent');
      expect(good.readinessLevel, 'Good');
      expect(fair.readinessLevel, 'Fair');
      expect(needsWork.readinessLevel, 'Needs Improvement');
    });
  });

  group('BenchmarkingDataModel', () {
    test('should determine performance level correctly', () {
      final top10 = BenchmarkingDataModel(
        percentileRank: 95.0,
        comparisonGroup: 'test',
        sectionPercentiles: {},
        insights: [],
        statistics: {},
      );

      final top25 = BenchmarkingDataModel(
        percentileRank: 80.0,
        comparisonGroup: 'test',
        sectionPercentiles: {},
        insights: [],
        statistics: {},
      );

      final aboveAverage = BenchmarkingDataModel(
        percentileRank: 60.0,
        comparisonGroup: 'test',
        sectionPercentiles: {},
        insights: [],
        statistics: {},
      );

      final belowAverage = BenchmarkingDataModel(
        percentileRank: 30.0,
        comparisonGroup: 'test',
        sectionPercentiles: {},
        insights: [],
        statistics: {},
      );

      final bottom25 = BenchmarkingDataModel(
        percentileRank: 15.0,
        comparisonGroup: 'test',
        sectionPercentiles: {},
        insights: [],
        statistics: {},
      );

      expect(top10.performanceLevel, 'Top 10%');
      expect(top25.performanceLevel, 'Top 25%');
      expect(aboveAverage.performanceLevel, 'Above Average');
      expect(belowAverage.performanceLevel, 'Below Average');
      expect(bottom25.performanceLevel, 'Bottom 25%');
    });
  });

  group('BenchmarkInsightModel', () {
    test('should identify severity levels correctly', () {
      final positive = BenchmarkInsightModel(
        type: 'test',
        message: 'Good job',
        severity: 'positive',
        data: {},
      );

      final warning = BenchmarkInsightModel(
        type: 'test',
        message: 'Be careful',
        severity: 'warning',
        data: {},
      );

      final negative = BenchmarkInsightModel(
        type: 'test',
        message: 'Needs work',
        severity: 'negative',
        data: {},
      );

      expect(positive.isPositive, true);
      expect(warning.isWarning, true);
      expect(negative.isNegative, true);
    });
  });

  group('AnalysisHistoryModel', () {
    test('should parse paginated results correctly', () {
      final json = {
        'results': [
          {
            'id': 'analysis-1',
            'cv_profile': 'cv-1',
            'user': 'user-1',
            'overall_score': 85.0,
            'section_scores': {},
            'recommendations': [],
            'submission_readiness': {
              'is_ready': true,
              'readiness_score': 85.0,
              'ready_aspects': [],
              'missing_aspects': [],
              'improvement_areas': [],
              'overall_assessment': '',
              'details': {},
            },
            'metadata': {},
            'analyzed_at': '2024-01-01T00:00:00Z',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ],
        'count': 1,
        'next': null,
        'previous': null,
        'current_page': 1,
        'total_pages': 1,
      };

      final model = AnalysisHistoryModel.fromJson(json);

      expect(model.analyses.length, 1);
      expect(model.totalCount, 1);
      expect(model.hasNext, false);
      expect(model.hasPrevious, false);
      expect(model.currentPage, 1);
      expect(model.totalPages, 1);
    });

    test('should handle empty results', () {
      final json = {
        'results': [],
        'count': 0,
      };

      final model = AnalysisHistoryModel.fromJson(json);

      expect(model.analyses.isEmpty, true);
      expect(model.totalCount, 0);
    });
  });

  group('Data parsing utilities', () {
    test('should parse double values correctly', () {
      expect(CVAnalysisModel._parseDouble(85), 85.0);
      expect(CVAnalysisModel._parseDouble(85.5), 85.5);
      expect(CVAnalysisModel._parseDouble('85.5'), 85.5);
      expect(CVAnalysisModel._parseDouble('invalid'), null);
      expect(CVAnalysisModel._parseDouble(null), null);
    });

    test('should parse DateTime values correctly', () {
      final validDate = '2024-01-01T00:00:00Z';
      final parsed = CVAnalysisModel._parseDateTime(validDate);
      
      expect(parsed, isNotNull);
      expect(parsed!.year, 2024);
      expect(parsed.month, 1);
      expect(parsed.day, 1);

      expect(CVAnalysisModel._parseDateTime('invalid'), null);
      expect(CVAnalysisModel._parseDateTime(null), null);
    });

    test('should parse string lists correctly', () {
      expect(SectionScoreModel._parseStringList(['a', 'b']), ['a', 'b']);
      expect(SectionScoreModel._parseStringList([]), []);
      expect(SectionScoreModel._parseStringList(null), []);
      expect(SectionScoreModel._parseStringList('invalid'), []);
    });
  });
}