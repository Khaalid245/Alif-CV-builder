import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';

import 'package:educv/core/network/api_client.dart';
import 'package:educv/core/network/api_response.dart';
import 'package:educv/core/exceptions/app_exception.dart';
import 'package:educv/features/cv_intelligence/data/repositories/cv_intelligence_repository_impl.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

import 'repository_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('CVIntelligenceRepositoryImpl Tests', () {
    late MockApiClient mockApiClient;
    late CVIntelligenceRepositoryImpl repository;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = CVIntelligenceRepositoryImpl(mockApiClient);
    });

    group('analyzeCV', () {
      test('should return analysis when API call succeeds', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Analysis completed successfully',
          'data': _mockAnalysisJson(),
        };

        when(mockApiClient.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.analyzeCV();

        // Assert
        expect(result, isA<CVAnalysisModel>());
        expect(result.id, equals('analysis-123'));
        expect(result.overallScore, equals(85.5));
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/cv-intelligence/analyze/',
          data: {},
        )).called(1);
      });

      test('should throw AppException when API returns error', () async {
        // Arrange
        final responseData = {
          'success': false,
          'message': 'Analysis failed',
        };

        when(mockApiClient.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(
          () => repository.analyzeCV(),
          throwsA(isA<AppException>()),
        );
      });

      test('should handle DioException', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ));

        // Act & Assert
        expect(
          () => repository.analyzeCV(),
          throwsA(isA<AppException>()),
        );
      });

      test('should pass options to API call', () async {
        // Arrange
        final options = {'detailed': true, 'sections': ['education', 'skills']};
        final responseData = {
          'success': true,
          'message': 'Analysis completed',
          'data': _mockAnalysisJson(),
        };

        when(mockApiClient.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        await repository.analyzeCV(options: options);

        // Assert
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/cv-intelligence/analyze/',
          data: options,
        )).called(1);
      });
    });

    group('getAnalysisHistory', () {
      test('should return paginated history', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'History retrieved successfully',
          'data': {
            'results': [_mockAnalysisJson()],
            'count': 1,
            'next': null,
            'previous': null,
            'current_page': 1,
            'total_pages': 1,
          },
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getAnalysisHistory(page: 2, pageSize: 5);

        // Assert
        expect(result, isA<AnalysisHistoryModel>());
        expect(result.analyses.length, equals(1));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/analysis/history/',
          queryParameters: {'page': 2, 'page_size': 5},
        )).called(1);
      });
    });

    group('getAnalysisById', () {
      test('should return specific analysis', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Analysis retrieved successfully',
          'data': _mockAnalysisJson(),
        };

        when(mockApiClient.get<Map<String, dynamic>>(any))
            .thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getAnalysisById('analysis-123');

        // Assert
        expect(result, isA<CVAnalysisModel>());
        expect(result.id, equals('analysis-123'));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/analysis/analysis-123/',
        )).called(1);
      });
    });

    group('getLatestAnalysis', () {
      test('should return latest analysis when available', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'History retrieved successfully',
          'data': {
            'results': [_mockAnalysisJson()],
            'count': 1,
            'next': null,
            'previous': null,
            'current_page': 1,
            'total_pages': 1,
          },
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getLatestAnalysis();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('analysis-123'));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/analysis/history/',
          queryParameters: {'page': 1, 'page_size': 1},
        )).called(1);
      });

      test('should return null when no analysis available', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'History retrieved successfully',
          'data': {
            'results': [],
            'count': 0,
            'next': null,
            'previous': null,
            'current_page': 1,
            'total_pages': 0,
          },
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getLatestAnalysis();

        // Assert
        expect(result, isNull);
      });

      test('should return null when error occurs', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getLatestAnalysis();

        // Assert
        expect(result, isNull);
      });
    });

    group('getRecommendations', () {
      test('should return filtered recommendations', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Recommendations retrieved successfully',
          'data': {
            'results': [_mockRecommendationJson()],
          },
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getRecommendations(
          category: 'skills',
          priority: 'high',
          includeImplemented: false,
        );

        // Assert
        expect(result, isA<List<RecommendationModel>>());
        expect(result.length, equals(1));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/recommendations/',
          queryParameters: {
            'category': 'skills',
            'priority': 'high',
            'include_implemented': false,
          },
        )).called(1);
      });

      test('should handle empty query parameters', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Recommendations retrieved successfully',
          'data': {'results': []},
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getRecommendations();

        // Assert
        expect(result, isA<List<RecommendationModel>>());
        expect(result.isEmpty, isTrue);
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/recommendations/',
          queryParameters: {},
        )).called(1);
      });
    });

    group('markRecommendationImplemented', () {
      test('should update recommendation status', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Recommendation updated successfully',
          'data': {},
        };

        when(mockApiClient.patch<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        await repository.markRecommendationImplemented('rec-123');

        // Assert
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/cv-intelligence/recommendations/rec-123/',
          data: {'is_implemented': true},
        )).called(1);
      });
    });

    group('getSubmissionReadiness', () {
      test('should return submission readiness data', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Submission readiness retrieved successfully',
          'data': _mockSubmissionReadinessJson(),
        };

        when(mockApiClient.get<Map<String, dynamic>>(any))
            .thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getSubmissionReadiness();

        // Assert
        expect(result, isA<SubmissionReadinessModel>());
        expect(result.isReady, isTrue);
        expect(result.readinessScore, equals(85.0));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/submission-readiness/',
        )).called(1);
      });
    });

    group('getBenchmarkingData', () {
      test('should return benchmarking data with comparison group', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Benchmarking data retrieved successfully',
          'data': _mockBenchmarkingDataJson(),
        };

        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getBenchmarkingData(
          comparisonGroup: 'computer_science',
        );

        // Assert
        expect(result, isA<BenchmarkingDataModel>());
        expect(result.percentileRank, equals(75.0));
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/benchmarking/',
          queryParameters: {'comparison_group': 'computer_science'},
        )).called(1);
      });
    });

    group('getAnalysisConfig', () {
      test('should return analysis configuration', () async {
        // Arrange
        final configData = {
          'analysis_depth': 'detailed',
          'sections_enabled': ['education', 'skills', 'experience'],
          'benchmarking_enabled': true,
        };
        final responseData = {
          'success': true,
          'message': 'Configuration retrieved successfully',
          'data': configData,
        };

        when(mockApiClient.get<Map<String, dynamic>>(any))
            .thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getAnalysisConfig();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['analysis_depth'], equals('detailed'));
        expect(result['benchmarking_enabled'], isTrue);
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/config/',
        )).called(1);
      });
    });

    group('updateAnalysisConfig', () {
      test('should update analysis configuration', () async {
        // Arrange
        final config = {
          'analysis_depth': 'basic',
          'sections_enabled': ['education', 'skills'],
        };
        final responseData = {
          'success': true,
          'message': 'Configuration updated successfully',
          'data': {},
        };

        when(mockApiClient.put<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        await repository.updateAnalysisConfig(config);

        // Assert
        verify(mockApiClient.put<Map<String, dynamic>>(
          '/cv-intelligence/config/',
          data: config,
        )).called(1);
      });
    });
  });
}

// Mock data helpers
Map<String, dynamic> _mockAnalysisJson() {
  return {
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
    'recommendations': [_mockRecommendationJson()],
    'submission_readiness': _mockSubmissionReadinessJson(),
    'benchmarking_data': null,
    'metadata': {'version': '1.0'},
    'analyzed_at': '2024-01-01T00:00:00Z',
    'created_at': '2024-01-01T00:00:00Z',
    'updated_at': '2024-01-01T00:00:00Z'
  };
}

Map<String, dynamic> _mockRecommendationJson() {
  return {
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
  };
}

Map<String, dynamic> _mockSubmissionReadinessJson() {
  return {
    'is_ready': true,
    'readiness_score': 85.0,
    'ready_aspects': ['Complete profile', 'Good formatting'],
    'missing_aspects': [],
    'improvement_areas': ['Add more skills'],
    'overall_assessment': 'Ready for submission',
    'details': {}
  };
}

Map<String, dynamic> _mockBenchmarkingDataJson() {
  return {
    'percentile_rank': 75.0,
    'comparison_group': 'Computer Science Students',
    'section_percentiles': {
      'education': 80.0,
      'skills': 70.0,
    },
    'insights': [
      {
        'type': 'performance',
        'message': 'Above average performance',
        'severity': 'positive',
        'data': {}
      }
    ],
    'statistics': {
      'total_comparisons': 1000,
      'average_score': 65.0,
    }
  };
}