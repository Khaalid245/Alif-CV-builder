import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:educv/core/network/api_client.dart';
import 'package:educv/core/network/api_response.dart';
import 'package:educv/core/exceptions/app_exception.dart';
import 'package:educv/features/cv_intelligence/data/repositories/cv_intelligence_repository_impl.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

import 'cv_intelligence_repository_impl_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late CVIntelligenceRepositoryImpl repository;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = CVIntelligenceRepositoryImpl(mockApiClient);
  });

  group('CVIntelligenceRepositoryImpl', () {
    group('analyzeCV', () {
      test('should return CVAnalysisModel on successful analysis', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Analysis completed',
          'data': {
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
              'overall_assessment': 'Good',
              'details': {},
            },
            'metadata': {},
            'analyzed_at': '2024-01-01T00:00:00Z',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
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
        expect(result.id, 'analysis-1');
        expect(result.overallScore, 85.0);
        verify(mockApiClient.post<Map<String, dynamic>>(
          '/cv-intelligence/analyze/',
          data: {},
        )).called(1);
      });

      test('should throw AppException on API error', () async {
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

      test('should throw AppException on DioException', () async {
        // Arrange
        when(mockApiClient.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ));

        // Act & Assert
        expect(
          () => repository.analyzeCV(),
          throwsA(isA<AppException>()),
        );
      });

      test('should pass options to API call', () async {
        // Arrange
        final options = {'detailed': true};
        final responseData = {
          'success': true,
          'message': 'Analysis completed',
          'data': {
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
              'overall_assessment': 'Good',
              'details': {},
            },
            'metadata': {},
            'analyzed_at': '2024-01-01T00:00:00Z',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
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
      test('should return AnalysisHistoryModel with pagination', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'History retrieved',
          'data': {
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
                  'overall_assessment': 'Good',
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
        final result = await repository.getAnalysisHistory(page: 1, pageSize: 10);

        // Assert
        expect(result, isA<AnalysisHistoryModel>());
        expect(result.analyses.length, 1);
        expect(result.totalCount, 1);
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/analysis/history/',
          queryParameters: {'page': 1, 'page_size': 10},
        )).called(1);
      });
    });

    group('getAnalysisById', () {
      test('should return specific analysis', () async {
        // Arrange
        const analysisId = 'analysis-1';
        final responseData = {
          'success': true,
          'message': 'Analysis retrieved',
          'data': {
            'id': analysisId,
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
              'overall_assessment': 'Good',
              'details': {},
            },
            'metadata': {},
            'analyzed_at': '2024-01-01T00:00:00Z',
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        };

        when(mockApiClient.get<Map<String, dynamic>>(any))
            .thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await repository.getAnalysisById(analysisId);

        // Assert
        expect(result, isA<CVAnalysisModel>());
        expect(result.id, analysisId);
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/analysis/$analysisId/',
        )).called(1);
      });
    });

    group('getLatestAnalysis', () {
      test('should return latest analysis when available', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'History retrieved',
          'data': {
            'results': [
              {
                'id': 'latest-analysis',
                'cv_profile': 'cv-1',
                'user': 'user-1',
                'overall_score': 90.0,
                'section_scores': {},
                'recommendations': [],
                'submission_readiness': {
                  'is_ready': true,
                  'readiness_score': 90.0,
                  'ready_aspects': [],
                  'missing_aspects': [],
                  'improvement_areas': [],
                  'overall_assessment': 'Excellent',
                  'details': {},
                },
                'metadata': {},
                'analyzed_at': '2024-01-02T00:00:00Z',
                'created_at': '2024-01-02T00:00:00Z',
                'updated_at': '2024-01-02T00:00:00Z',
              },
            ],
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
        expect(result!.id, 'latest-analysis');
        expect(result.overallScore, 90.0);
      });

      test('should return null when no analysis available', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'History retrieved',
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

      test('should return null on error', () async {
        // Arrange
        when(mockApiClient.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
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
          'message': 'Recommendations retrieved',
          'data': {
            'results': [
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
          category: 'education',
          priority: 'high',
          includeImplemented: false,
        );

        // Assert
        expect(result, isA<List<RecommendationModel>>());
        expect(result.length, 1);
        expect(result.first.category, 'education');
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/recommendations/',
          queryParameters: {
            'category': 'education',
            'priority': 'high',
            'include_implemented': false,
          },
        )).called(1);
      });
    });

    group('markRecommendationImplemented', () {
      test('should mark recommendation as implemented', () async {
        // Arrange
        const recommendationId = 'rec-1';
        final responseData = {
          'success': true,
          'message': 'Recommendation updated',
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
        await repository.markRecommendationImplemented(recommendationId);

        // Assert
        verify(mockApiClient.patch<Map<String, dynamic>>(
          '/cv-intelligence/recommendations/$recommendationId/',
          data: {'is_implemented': true},
        )).called(1);
      });
    });

    group('getSubmissionReadiness', () {
      test('should return submission readiness data', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Readiness retrieved',
          'data': {
            'is_ready': true,
            'readiness_score': 85.0,
            'ready_aspects': ['Education complete'],
            'missing_aspects': [],
            'improvement_areas': ['Add more experience'],
            'overall_assessment': 'Good to go',
            'details': {},
          },
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
        expect(result.isReady, true);
        expect(result.readinessScore, 85.0);
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/submission-readiness/',
        )).called(1);
      });
    });

    group('getBenchmarkingData', () {
      test('should return benchmarking data', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Benchmarking data retrieved',
          'data': {
            'percentile_rank': 75.0,
            'comparison_group': 'computer_science',
            'section_percentiles': {
              'education': 80.0,
              'experience': 70.0,
            },
            'insights': [],
            'statistics': {},
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
        final result = await repository.getBenchmarkingData(
          comparisonGroup: 'computer_science',
        );

        // Assert
        expect(result, isA<BenchmarkingDataModel>());
        expect(result.percentileRank, 75.0);
        expect(result.comparisonGroup, 'computer_science');
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/benchmarking/',
          queryParameters: {'comparison_group': 'computer_science'},
        )).called(1);
      });
    });

    group('getAnalysisConfig', () {
      test('should return analysis configuration', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Config retrieved',
          'data': {
            'detailed_analysis': true,
            'include_benchmarking': true,
            'recommendation_limit': 10,
          },
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
        expect(result['detailed_analysis'], true);
        verify(mockApiClient.get<Map<String, dynamic>>(
          '/cv-intelligence/config/',
        )).called(1);
      });
    });

    group('updateAnalysisConfig', () {
      test('should update analysis configuration', () async {
        // Arrange
        final config = {
          'detailed_analysis': false,
          'recommendation_limit': 5,
        };
        final responseData = {
          'success': true,
          'message': 'Config updated',
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