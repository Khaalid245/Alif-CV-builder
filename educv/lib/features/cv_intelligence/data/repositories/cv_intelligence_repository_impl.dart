import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/cv_intelligence_repository.dart';
import '../models/cv_intelligence_models.dart';

class CVIntelligenceRepositoryImpl implements CVIntelligenceRepository {
  final ApiClient _apiClient;

  CVIntelligenceRepositoryImpl(this._apiClient);

  @override
  Future<CVAnalysisModel> analyzeCV({
    Map<String, dynamic>? options,
  }) async {
    try {
      // Use POST to the analyze endpoint to force new analysis
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.cvAnalyze,
        data: options ?? {},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Analysis failed',
        );
      }

      final analysisData = apiResponse.data ?? {};
      
      // Transform backend response to match model expectations
      final transformedData = {
        'id': analysisData['id'] ?? '',
        'cv_profile': analysisData['cv_profile'] ?? '',
        'user': analysisData['user'] ?? '',
        'overall_score': analysisData['overall_score'] ?? 0.0,
        'section_scores': _transformSectionScores(analysisData),
        'recommendations': _transformRecommendations(analysisData['recommendations']),
        'submission_readiness': _transformSubmissionReadiness(analysisData),
        'benchmarking_data': null, // Will be loaded separately
        'metadata': {},
        'analyzed_at': analysisData['analyzed_at'] ?? DateTime.now().toIso8601String(),
        'created_at': analysisData['analyzed_at'] ?? DateTime.now().toIso8601String(),
        'updated_at': analysisData['last_updated'] ?? DateTime.now().toIso8601String(),
      };

      return CVAnalysisModel.fromJson(transformedData);
    } on DioException catch (e) {
      final appException = e.error;
      if (appException is AppException) {
        throw appException;
      }
      throw AppException(message: 'Network error: ${e.message ?? "Connection failed"}');
    } catch (e) {
      throw AppException(
        message: 'Failed to analyze CV: ${e.toString()}',
      );
    }
  }

  @override
  Future<AnalysisHistoryModel> getAnalysisHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.cvAnalysisHistory, // This maps to /cv/analysis/history/
        queryParameters: {
          'limit': pageSize,
          'offset': (page - 1) * pageSize,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get analysis history',
        );
      }

      final data = apiResponse.data ?? {};
      final results = data['results'] as List<dynamic>? ?? [];
      final totalCount = data['total'] as int? ?? data['count'] as int? ?? 0;
      final hasNext = data['has_next'] as bool? ?? false;
      final hasPrevious = data['has_previous'] as bool? ?? false;
      
      final analyses = results.map((item) {
        final historyItem = item as Map<String, dynamic>;
        return CVAnalysisModel(
          id: historyItem['id']?.toString() ?? '',
          cvProfileId: '',
          userId: '',
          overallScore: _parseDouble(historyItem['overall_score']) ?? 0.0,
          sectionScores: _parseSectionScoresFromHistory(historyItem['section_scores']),
          recommendations: _parseRecommendationsFromHistory(historyItem['recommendations']),
          submissionReadiness: SubmissionReadinessModel(
            isReady: (_parseDouble(historyItem['readiness_score']) ?? 0.0) >= 70,
            readinessScore: _parseDouble(historyItem['readiness_score']) ?? 0.0,
            readyAspects: [],
            missingAspects: [],
            improvementAreas: [],
            overallAssessment: historyItem['readiness_grade']?.toString() ?? 'F',
            details: {},
          ),
          benchmarkingData: null,
          metadata: {},
          analyzedAt: _parseDateTime(historyItem['created_at']) ?? DateTime.now(),
          createdAt: _parseDateTime(historyItem['created_at']) ?? DateTime.now(),
          updatedAt: _parseDateTime(historyItem['created_at']) ?? DateTime.now(),
        );
      }).toList();
      
      final totalPages = totalCount > 0 ? (totalCount / pageSize).ceil() : 1;
      
      return AnalysisHistoryModel(
        analyses: analyses,
        totalCount: totalCount,
        currentPage: page,
        totalPages: totalPages,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
      );
    } on DioException catch (e) {
      final appException = e.error;
      if (appException is AppException) {
        throw appException;
      }
      throw AppException(message: 'Network error: ${e.message ?? "Connection failed"}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get analysis history: ${e.toString()}',
      );
    }
  }

  @override
  Future<CVAnalysisModel> getAnalysisById(String analysisId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.cvAnalysisHistoryDetail(analysisId), // This maps to /cv/analysis/history/{id}/
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Analysis not found',
        );
      }

      final historyItem = apiResponse.data ?? {};
      return CVAnalysisModel(
        id: historyItem['id'] ?? '',
        cvProfileId: '',
        userId: '',
        overallScore: (historyItem['overall_score'] ?? 0).toDouble(),
        sectionScores: _parseSectionScoresFromHistory(historyItem['section_scores']),
        recommendations: _parseRecommendationsFromHistory(historyItem['recommendations']),
        submissionReadiness: SubmissionReadinessModel(
          isReady: (historyItem['readiness_score'] ?? 0) >= 70,
          readinessScore: (historyItem['readiness_score'] ?? 0).toDouble(),
          readyAspects: [],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: historyItem['readiness_grade'] ?? 'F',
          details: {},
        ),
        benchmarkingData: null,
        metadata: {},
        analyzedAt: DateTime.tryParse(historyItem['created_at'] ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(historyItem['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(historyItem['created_at'] ?? '') ?? DateTime.now(),
      );
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get analysis: ${e.toString()}',
      );
    }
  }

  @override
  Future<CVAnalysisModel?> getLatestAnalysis() async {
    try {
      // Use the score endpoint instead of analyze endpoint to avoid auto-creation
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.cvScore,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (!apiResponse.success) {
        // Check if it's a "no analysis found" case
        final message = apiResponse.message?.toLowerCase() ?? '';
        if (message.contains('not found') || message.contains('no analysis')) {
          return null; // Return null instead of throwing error
        }
        throw AppException(message: apiResponse.message ?? 'Failed to get analysis');
      }

      final analysisData = apiResponse.data ?? {};
      
      // Check if analysis is available
      if (analysisData['analysis_available'] == false) {
        return null; // No analysis data available
      }
      
      // Transform backend response to match model expectations
      final transformedData = {
        'id': analysisData['analysis_id'] ?? '',
        'cv_profile': '',
        'user': '',
        'overall_score': analysisData['overall_score'] ?? 0.0,
        'section_scores': _transformSectionScoresFromScore(analysisData['score_breakdown']),
        'recommendations': _transformRecommendations(analysisData['recommendations']),
        'submission_readiness': {
          'is_ready': analysisData['is_submission_ready'] ?? false,
          'readiness_score': analysisData['overall_score'] ?? 0.0,
          'ready_aspects': [],
          'missing_aspects': [],
          'improvement_areas': [],
          'overall_assessment': analysisData['grade']?.toString() ?? 'F',
          'details': {},
        },
        'benchmarking_data': null, // Will be loaded separately
        'metadata': {},
        'analyzed_at': analysisData['analysis_date'] ?? DateTime.now().toIso8601String(),
        'created_at': analysisData['analysis_date'] ?? DateTime.now().toIso8601String(),
        'updated_at': analysisData['last_updated'] ?? DateTime.now().toIso8601String(),
      };

      return CVAnalysisModel.fromJson(transformedData);
    } on DioException catch (e) {
      // Handle 404 as "no analysis found"
      if (e.response?.statusCode == 404) {
        return null;
      }
      
      final appException = e.error;
      if (appException is AppException) {
        throw appException;
      }
      throw AppException(message: 'Network error: ${e.message ?? "Connection failed"}');
    } catch (e) {
      // Don't throw for parsing errors, return null
      if (e.toString().contains('FormatException') || e.toString().contains('parsing')) {
        return null;
      }
      throw AppException(
        message: 'Failed to get latest analysis: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<RecommendationModel>> getRecommendations({
    String? category,
    String? priority,
    bool? includeImplemented,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.cvScore,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (!apiResponse.success) {
        // If no analysis exists, return empty recommendations instead of error
        final message = apiResponse.message?.toLowerCase() ?? '';
        if (message.contains('not found') || message.contains('no analysis')) {
          return [];
        }
        throw AppException(
          message: apiResponse.message ?? 'Failed to get recommendations',
        );
      }

      final data = apiResponse.data ?? {};
      final recommendationsData = data['recommendations'] ?? {};
      
      // If no recommendations data, return empty list
      if (recommendationsData.isEmpty) {
        return [];
      }
      
      final List<RecommendationModel> recommendations = [];
      
      // Extract recommendations from different categories
      final categories = {
        'critical': recommendationsData['critical'] ?? [],
        'important': recommendationsData['important'] ?? [],
        'suggestions': recommendationsData['suggestions'] ?? [],
        'strengths': recommendationsData['strengths'] ?? [],
      };
      
      // Convert to RecommendationModel objects with proper error handling
      categories.forEach((categoryName, items) {
        if (items is List) {
          for (int i = 0; i < items.length; i++) {
            try {
              final item = items[i];
              String title = 'Recommendation ${i + 1}';
              String description = 'No description available';
              
              // Safe extraction of title and description
              if (item is Map<String, dynamic>) {
                title = item['title']?.toString() ?? title;
                description = item['description']?.toString() ?? 
                             item['message']?.toString() ?? 
                             description;
              } else if (item is String) {
                description = item;
                title = 'Improve ${categoryName.substring(0, 1).toUpperCase()}${categoryName.substring(1)}';
              }
              
              final recommendationData = {
                'id': '${categoryName}_$i',
                'title': title,
                'description': description,
                'category': categoryName,
                'priority': _mapCategoryToPriority(categoryName),
                'action_text': 'View Details',
                'action_url': null,
                'metadata': {},
                'is_implemented': false,
                'created_at': DateTime.now().toIso8601String(),
              };
              
              recommendations.add(RecommendationModel.fromJson(recommendationData));
            } catch (e) {
              // Skip malformed recommendation but continue processing
              continue;
            }
          }
        }
      });
      
      return recommendations;
    } on DioException catch (e) {
      // Handle 404 as "no recommendations found"
      if (e.response?.statusCode == 404) {
        return [];
      }
      
      final appException = e.error;
      if (appException is AppException) {
        throw appException;
      }
      throw AppException(message: 'Network error: ${e.message ?? "Connection failed"}');
    } catch (e) {
      // Return empty list for parsing errors instead of throwing
      if (e.toString().contains('FormatException') || e.toString().contains('parsing')) {
        return [];
      }
      throw AppException(
        message: 'Failed to get recommendations: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> markRecommendationImplemented(String recommendationId) async {
    try {
      // Since backend doesn't support individual recommendation updates,
      // this is a no-op for now
      return;
    } catch (e) {
      throw AppException(
        message: 'Failed to update recommendation: ${e.toString()}',
      );
    }
  }

  @override
  Future<SubmissionReadinessModel> getSubmissionReadiness() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.cvScore,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data!, (data) => data as Map<String, dynamic>);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get submission readiness',
        );
      }

      final data = apiResponse.data ?? {};
      return SubmissionReadinessModel(
        isReady: data['is_submission_ready'] ?? false,
        readinessScore: (data['overall_score'] ?? 0).toDouble(),
        readyAspects: [],
        missingAspects: [],
        improvementAreas: [],
        overallAssessment: data['grade'] ?? 'F',
        details: {},
      );
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get submission readiness: ${e.toString()}',
      );
    }
  }

  @override
  Future<BenchmarkingDataModel> getBenchmarkingData({
    String? comparisonGroup,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (comparisonGroup != null && comparisonGroup != 'all') {
        queryParams['group'] = comparisonGroup;
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.cvBenchmarking,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get benchmarking data',
        );
      }

      final data = apiResponse.data ?? {};
      
      return BenchmarkingDataModel(
        userId: data['user_id']?.toString() ?? 'current_user',
        currentScore: _parseDouble(data['current_score']) ?? 0.0,
        percentileRank: _parseDouble(data['percentile_rank']) ?? 0.0,
        totalPeers: data['total_participants'] ?? 0,
        groups: [data['comparison_group']?.toString() ?? 'all_students'],
        summary: _generateSummary(data),
        peerComparisons: _parsePeerComparisons(data),
        comparisonGroup: comparisonGroup ?? 'all_students',
        sectionPercentiles: _parseSectionPercentiles(data['section_percentiles']),
        insights: _parseInsights(data['benchmark_insights']),
        statistics: _parseStatistics(data['statistics']),
      );
    } on DioException catch (e) {
      final appException = e.error;
      if (appException is AppException) {
        throw appException;
      }
      throw AppException(message: 'Network error: ${e.message ?? "Connection failed"}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get benchmarking data: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAnalysisConfig() async {
    try {
      // Return default config since backend doesn't support this yet
      return {
        'analysis_enabled': true,
        'auto_analysis': false,
        'notification_preferences': {
          'email_notifications': true,
          'push_notifications': true,
        },
        'analysis_frequency': 'manual',
      };
    } catch (e) {
      throw AppException(
        message: 'Failed to get analysis config: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasCVProfile() async {
    try {
      // Check if user has a CV profile by calling a lightweight endpoint
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/cv/profile/', // Check CV profile endpoint
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data!, 
        (data) => data as Map<String, dynamic>
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        final profileData = apiResponse.data!;
        // Check if profile has minimum required data
        final hasBasicInfo = profileData['first_name'] != null && profileData['last_name'] != null;
        final hasContact = profileData['email'] != null || profileData['phone'] != null;
        
        return hasBasicInfo && hasContact;
      }
      
      return false;
    } catch (e) {
      return false; // Assume no CV if we can't check
    }
  }

  @override
  Future<String> exportAnalysisReport() async {
    try {
      final response = await _apiClient.get<List<int>>(
        ApiConstants.cvExportAnalysis,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Get filename from Content-Disposition header
        final contentDisposition = response.headers.value('content-disposition');
        String filename = 'cv_analysis_report.pdf';
        
        if (contentDisposition != null) {
          final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
          if (filenameMatch != null) {
            filename = filenameMatch.group(1) ?? filename;
          }
        }

        // Save file to downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(response.data!);
        
        return file.path;
      }
      
      throw AppException(message: 'Failed to download analysis report');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw AppException(message: 'No analysis found. Please run an analysis first.');
      }
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to export analysis report: ${e.toString()}',
      );
    }
  }

  // Helper methods for parsing history data
  List<RecommendationModel> _parseRecommendationsFromHistory(dynamic recommendations) {
    if (recommendations is List) {
      return recommendations.map((r) {
        final rec = r as Map<String, dynamic>;
        return RecommendationModel(
          id: rec['id']?.toString() ?? '',
          category: rec['category']?.toString() ?? 'general',
          priority: rec['priority']?.toString() ?? 'medium',
          title: rec['title']?.toString() ?? '',
          description: rec['description']?.toString() ?? '',
          actionText: 'View Details',
          actionUrl: null,
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );
      }).toList();
    }
    return [];
  }

  Map<String, SectionScoreModel> _parseSectionScoresFromHistory(dynamic sectionScores) {
    if (sectionScores is Map<String, dynamic>) {
      return sectionScores.map((key, value) {
        final score = _parseDouble(value) ?? 0.0;
        return MapEntry(
          key,
          SectionScoreModel(
            score: score,
            maxScore: 100.0,
            weight: 1.0,
            status: score >= 70 ? 'good' : 'needs_improvement',
            strengths: [],
            weaknesses: [],
            suggestions: [],
            details: {},
          ),
        );
      });
    }
    return {};
  }

  // Helper methods for data transformation
  Map<String, dynamic> _transformSectionScores(Map<String, dynamic> data) {
    final sectionScores = <String, dynamic>{};
    
    // Map backend fields to section scores
    final scoreMapping = {
      'profile': data['profile_score'],
      'experience': data['experience_score'],
      'education': data['education_score'],
      'skills': data['skills_score'],
      'projects': data['projects_score'],
    };
    
    scoreMapping.forEach((section, score) {
      if (score != null) {
        final scoreValue = _parseDouble(score) ?? 0.0;
        sectionScores[section] = {
          'score': scoreValue,
          'max_score': 100.0,
          'weight': 1.0,
          'status': scoreValue >= 70 ? 'good' : 'needs_improvement',
          'strengths': [],
          'weaknesses': [],
          'suggestions': [],
          'details': {},
        };
      }
    });
    
    return sectionScores;
  }

  Map<String, dynamic> _transformSectionScoresFromScore(dynamic scoreBreakdown) {
    final sectionScores = <String, dynamic>{};
    
    if (scoreBreakdown is Map<String, dynamic>) {
      scoreBreakdown.forEach((section, score) {
        if (score != null) {
          final scoreValue = _parseDouble(score) ?? 0.0;
          sectionScores[section] = {
            'score': scoreValue,
            'max_score': 100.0,
            'weight': 1.0,
            'status': scoreValue >= 70 ? 'good' : 'needs_improvement',
            'strengths': [],
            'weaknesses': [],
            'suggestions': [],
            'details': {},
          };
        }
      });
    }
    
    return sectionScores;
  }

  List<dynamic> _transformRecommendations(dynamic recommendations) {
    if (recommendations == null) return [];
    
    final List<dynamic> transformedRecs = [];
    
    if (recommendations is Map<String, dynamic>) {
      // Handle nested recommendation structure
      recommendations.forEach((category, items) {
        if (items is List) {
          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            String title = 'Recommendation ${i + 1}';
            String description = 'No description available';
            
            // Safe extraction of title and description
            if (item is Map<String, dynamic>) {
              title = item['title']?.toString() ?? title;
              description = item['description']?.toString() ?? 
                           item['message']?.toString() ?? 
                           description;
            } else if (item is String) {
              description = item;
              title = 'Improve ${category.substring(0, 1).toUpperCase()}${category.substring(1)}';
            }
            
            transformedRecs.add({
              'id': '${category}_$i',
              'title': title,
              'description': description,
              'category': category,
              'priority': _mapCategoryToPriority(category),
              'action_text': 'View Details',
              'action_url': null,
              'metadata': {},
              'is_implemented': false,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
      });
    } else if (recommendations is List) {
      // Handle flat list structure
      transformedRecs.addAll(recommendations);
    }
    
    return transformedRecs;
  }

  Map<String, dynamic> _transformSubmissionReadiness(Map<String, dynamic> data) {
    return {
      'is_ready': data['is_submission_ready'] ?? false,
      'readiness_score': _parseDouble(data['overall_score']) ?? 0.0,
      'ready_aspects': [],
      'missing_aspects': [],
      'improvement_areas': [],
      'overall_assessment': data['grade']?.toString() ?? 'F',
      'details': {},
    };
  }

  // Utility methods
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String? _extractString(dynamic item, String key) {
    if (item is Map<String, dynamic>) {
      return item[key]?.toString();
    }
    return null;
  }

  String _mapCategoryToPriority(String category) {
    switch (category.toLowerCase()) {
      case 'critical':
        return 'high';
      case 'important':
        return 'medium';
      case 'suggestions':
      case 'strengths':
        return 'low';
      default:
        return 'medium';
    }
  }

  // Helper methods for parsing benchmarking data
  String _generateSummary(Map<String, dynamic> data) {
    final percentile = (data['percentile_rank'] ?? 0).toDouble();
    final performanceLevel = data['performance_level'] ?? 'average';
    final totalParticipants = data['total_participants'] ?? 0;
    
    return 'You rank in the ${percentile.toStringAsFixed(0)}th percentile '
           'among $totalParticipants students with $performanceLevel performance.';
  }
  
  List<String> _parsePeerComparisons(Map<String, dynamic> data) {
    final comparisons = <String>[];
    
    final averageScore = (data['average_score'] ?? 0).toDouble();
    final topScore = (data['top_score'] ?? 0).toDouble();
    final userRank = data['user_rank'] ?? 0;
    final totalParticipants = data['total_participants'] ?? 0;
    
    comparisons.add('Average score: ${averageScore.toStringAsFixed(1)}');
    comparisons.add('Top score: ${topScore.toStringAsFixed(1)}');
    comparisons.add('Your rank: #$userRank out of $totalParticipants');
    
    return comparisons;
  }
  
  Map<String, double> _parseSectionPercentiles(dynamic sectionPercentiles) {
    if (sectionPercentiles is Map<String, dynamic>) {
      return sectionPercentiles.map(
        (key, value) => MapEntry(key, (value ?? 0).toDouble())
      );
    }
    return {};
  }
  
  List<BenchmarkInsightModel> _parseInsights(dynamic insights) {
    if (insights is List) {
      return insights.map((insight) {
        return BenchmarkInsightModel(
          type: 'benchmark',
          message: insight.toString(),
          severity: 'info',
          data: {},
        );
      }).toList();
    }
    return [];
  }
  
  Map<String, dynamic> _parseStatistics(dynamic statistics) {
    if (statistics is Map<String, dynamic>) {
      return Map<String, dynamic>.from(statistics);
    }
    return {};
  }
}