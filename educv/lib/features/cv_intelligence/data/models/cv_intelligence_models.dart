/// CV Intelligence data models for EduCV
/// Production-quality models with comprehensive error handling and validation

class CVAnalysisModel {
  final String id;
  final String cvProfileId;
  final String userId;
  final double overallScore;
  final Map<String, SectionScoreModel> sectionScores;
  final List<RecommendationModel> recommendations;
  final SubmissionReadinessModel submissionReadiness;
  final BenchmarkingDataModel? benchmarkingData;
  final Map<String, dynamic> metadata;
  final DateTime analyzedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CVAnalysisModel({
    required this.id,
    required this.cvProfileId,
    required this.userId,
    required this.overallScore,
    required this.sectionScores,
    required this.recommendations,
    required this.submissionReadiness,
    this.benchmarkingData,
    required this.metadata,
    required this.analyzedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CVAnalysisModel.fromJson(Map<String, dynamic> json) {
    try {
      return CVAnalysisModel(
        id: json['id']?.toString() ?? '',
        cvProfileId: json['cv_profile']?.toString() ?? '',
        userId: json['user']?.toString() ?? '',
        overallScore: _parseDouble(json['overall_score']) ?? 0.0,
        sectionScores: _parseSectionScores(json['section_scores'] ?? json),
        recommendations: _parseRecommendations(json['recommendations']),
        submissionReadiness: SubmissionReadinessModel.fromJson(
          json['submission_readiness'] ?? _buildSubmissionReadinessFromScore(json),
        ),
        benchmarkingData: json['benchmarking_data'] != null
            ? BenchmarkingDataModel.fromJson(json['benchmarking_data'])
            : null,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        analyzedAt: _parseDateTime(json['analyzed_at']) ?? DateTime.now(),
        createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse CVAnalysisModel: $e');
    }
  }

  static Map<String, SectionScoreModel> _parseSectionScores(dynamic data) {
    if (data == null) return {};
    try {
      // Handle both nested object and flat score structure
      if (data is Map<String, dynamic>) {
        final Map<String, SectionScoreModel> sectionScores = {};
        
        // Check if it's already in the expected format
        if (data.containsKey('profile') && data['profile'] is Map) {
          return data.map(
            (key, value) => MapEntry(
              key,
              SectionScoreModel.fromJson(Map<String, dynamic>.from(value)),
            ),
          );
        }
        
        // Handle flat score structure from backend
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
            sectionScores[section] = SectionScoreModel(
              score: scoreValue,
              maxScore: 100.0,
              weight: 1.0,
              status: scoreValue >= 70 ? 'good' : 'needs_improvement',
              strengths: [],
              weaknesses: [],
              suggestions: [],
              details: {},
            );
          }
        });
        
        return sectionScores;
      }
    } catch (e) {
      return {};
    }
    return {};
  }

  static List<RecommendationModel> _parseRecommendations(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> recommendationsList = List<dynamic>.from(data);
      return recommendationsList
          .map((item) => RecommendationModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
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

  static Map<String, dynamic> _buildSubmissionReadinessFromScore(Map<String, dynamic> json) {
    final overallScore = _parseDouble(json['overall_score']) ?? 0.0;
    return {
      'is_ready': json['is_submission_ready'] ?? overallScore >= 70,
      'readiness_score': overallScore,
      'ready_aspects': [],
      'missing_aspects': [],
      'improvement_areas': [],
      'overall_assessment': json['grade']?.toString() ?? 'F',
      'details': {},
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cv_profile': cvProfileId,
      'user': userId,
      'overall_score': overallScore,
      'section_scores': sectionScores.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'submission_readiness': submissionReadiness.toJson(),
      'benchmarking_data': benchmarkingData?.toJson(),
      'metadata': metadata,
      'analyzed_at': analyzedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CVAnalysisModel copyWith({
    String? id,
    String? cvProfileId,
    String? userId,
    double? overallScore,
    Map<String, SectionScoreModel>? sectionScores,
    List<RecommendationModel>? recommendations,
    SubmissionReadinessModel? submissionReadiness,
    BenchmarkingDataModel? benchmarkingData,
    Map<String, dynamic>? metadata,
    DateTime? analyzedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CVAnalysisModel(
      id: id ?? this.id,
      cvProfileId: cvProfileId ?? this.cvProfileId,
      userId: userId ?? this.userId,
      overallScore: overallScore ?? this.overallScore,
      sectionScores: sectionScores ?? this.sectionScores,
      recommendations: recommendations ?? this.recommendations,
      submissionReadiness: submissionReadiness ?? this.submissionReadiness,
      benchmarkingData: benchmarkingData ?? this.benchmarkingData,
      metadata: metadata ?? this.metadata,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SectionScoreModel {
  final double score;
  final double maxScore;
  final double weight;
  final String status;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;
  final Map<String, dynamic> details;

  const SectionScoreModel({
    required this.score,
    required this.maxScore,
    required this.weight,
    required this.status,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
    required this.details,
  });

  factory SectionScoreModel.fromJson(Map<String, dynamic> json) {
    try {
      return SectionScoreModel(
        score: CVAnalysisModel._parseDouble(json['score']) ?? 0.0,
        maxScore: CVAnalysisModel._parseDouble(json['max_score']) ?? 100.0,
        weight: CVAnalysisModel._parseDouble(json['weight']) ?? 1.0,
        status: json['status']?.toString() ?? 'unknown',
        strengths: _parseStringList(json['strengths']),
        weaknesses: _parseStringList(json['weaknesses']),
        suggestions: _parseStringList(json['suggestions']),
        details: Map<String, dynamic>.from(json['details'] ?? {}),
      );
    } catch (e) {
      throw FormatException('Failed to parse SectionScoreModel: $e');
    }
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    try {
      return List<String>.from(data);
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'max_score': maxScore,
      'weight': weight,
      'status': status,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'suggestions': suggestions,
      'details': details,
    };
  }

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0.0;

  bool get isExcellent => percentage >= 90;
  bool get isGood => percentage >= 70;
  bool get isAverage => percentage >= 50;
  bool get isPoor => percentage < 50;

  SectionScoreModel copyWith({
    double? score,
    double? maxScore,
    double? weight,
    String? status,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? suggestions,
    Map<String, dynamic>? details,
  }) {
    return SectionScoreModel(
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      suggestions: suggestions ?? this.suggestions,
      details: details ?? this.details,
    );
  }
}

class RecommendationModel {
  final String id;
  final String category;
  final String priority;
  final String title;
  final String description;
  final String actionText;
  final String? actionUrl;
  final Map<String, dynamic> metadata;
  final bool isImplemented;
  final DateTime createdAt;

  const RecommendationModel({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionText,
    this.actionUrl,
    required this.metadata,
    required this.isImplemented,
    required this.createdAt,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    try {
      return RecommendationModel(
        id: json['id']?.toString() ?? '',
        category: json['category']?.toString() ?? 'general',
        priority: json['priority']?.toString() ?? 'medium',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        actionText: json['action_text']?.toString() ?? '',
        actionUrl: json['action_url']?.toString(),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        isImplemented: json['is_implemented'] == true,
        createdAt: CVAnalysisModel._parseDateTime(json['created_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse RecommendationModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'priority': priority,
      'title': title,
      'description': description,
      'action_text': actionText,
      'action_url': actionUrl,
      'metadata': metadata,
      'is_implemented': isImplemented,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isHighPriority => priority.toLowerCase() == 'high';
  bool get isMediumPriority => priority.toLowerCase() == 'medium';
  bool get isLowPriority => priority.toLowerCase() == 'low';

  RecommendationModel copyWith({
    String? id,
    String? category,
    String? priority,
    String? title,
    String? description,
    String? actionText,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    bool? isImplemented,
    DateTime? createdAt,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      actionText: actionText ?? this.actionText,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      isImplemented: isImplemented ?? this.isImplemented,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SubmissionReadinessModel {
  final bool isReady;
  final double readinessScore;
  final List<String> readyAspects;
  final List<String> missingAspects;
  final List<String> improvementAreas;
  final String overallAssessment;
  final Map<String, dynamic> details;

  const SubmissionReadinessModel({
    required this.isReady,
    required this.readinessScore,
    required this.readyAspects,
    required this.missingAspects,
    required this.improvementAreas,
    required this.overallAssessment,
    required this.details,
  });

  factory SubmissionReadinessModel.fromJson(Map<String, dynamic> json) {
    try {
      return SubmissionReadinessModel(
        isReady: json['is_ready'] == true,
        readinessScore: CVAnalysisModel._parseDouble(json['readiness_score']) ?? 0.0,
        readyAspects: SectionScoreModel._parseStringList(json['ready_aspects']),
        missingAspects: SectionScoreModel._parseStringList(json['missing_aspects']),
        improvementAreas: SectionScoreModel._parseStringList(json['improvement_areas']),
        overallAssessment: json['overall_assessment']?.toString() ?? '',
        details: Map<String, dynamic>.from(json['details'] ?? {}),
      );
    } catch (e) {
      throw FormatException('Failed to parse SubmissionReadinessModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'is_ready': isReady,
      'readiness_score': readinessScore,
      'ready_aspects': readyAspects,
      'missing_aspects': missingAspects,
      'improvement_areas': improvementAreas,
      'overall_assessment': overallAssessment,
      'details': details,
    };
  }

  String get readinessLevel {
    if (readinessScore >= 90) return 'Excellent';
    if (readinessScore >= 75) return 'Good';
    if (readinessScore >= 60) return 'Fair';
    return 'Needs Improvement';
  }

  SubmissionReadinessModel copyWith({
    bool? isReady,
    double? readinessScore,
    List<String>? readyAspects,
    List<String>? missingAspects,
    List<String>? improvementAreas,
    String? overallAssessment,
    Map<String, dynamic>? details,
  }) {
    return SubmissionReadinessModel(
      isReady: isReady ?? this.isReady,
      readinessScore: readinessScore ?? this.readinessScore,
      readyAspects: readyAspects ?? this.readyAspects,
      missingAspects: missingAspects ?? this.missingAspects,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      overallAssessment: overallAssessment ?? this.overallAssessment,
      details: details ?? this.details,
    );
  }
}

class BenchmarkingDataModel {
  final String userId;
  final double currentScore;
  final double percentileRank;
  final int totalPeers;
  final List<String> groups;
  final String summary;
  final List<String> peerComparisons;
  final String comparisonGroup;
  final Map<String, double> sectionPercentiles;
  final List<BenchmarkInsightModel> insights;
  final Map<String, dynamic> statistics;

  const BenchmarkingDataModel({
    required this.userId,
    required this.currentScore,
    required this.percentileRank,
    required this.totalPeers,
    required this.groups,
    required this.summary,
    required this.peerComparisons,
    required this.comparisonGroup,
    required this.sectionPercentiles,
    required this.insights,
    required this.statistics,
  });

  factory BenchmarkingDataModel.fromJson(Map<String, dynamic> json) {
    try {
      return BenchmarkingDataModel(
        userId: json['user_id']?.toString() ?? '',
        currentScore: CVAnalysisModel._parseDouble(json['current_score']) ?? 0.0,
        percentileRank: CVAnalysisModel._parseDouble(json['percentile_rank']) ?? 0.0,
        totalPeers: json['total_peers'] ?? 0,
        groups: SectionScoreModel._parseStringList(json['groups']),
        summary: json['summary']?.toString() ?? '',
        peerComparisons: SectionScoreModel._parseStringList(json['peer_comparisons']),
        comparisonGroup: json['comparison_group']?.toString() ?? '',
        sectionPercentiles: _parseSectionPercentiles(json['section_percentiles']),
        insights: _parseInsights(json['insights']),
        statistics: Map<String, dynamic>.from(json['statistics'] ?? {}),
      );
    } catch (e) {
      throw FormatException('Failed to parse BenchmarkingDataModel: $e');
    }
  }

  static Map<String, double> _parseSectionPercentiles(dynamic data) {
    if (data == null) return {};
    try {
      final Map<String, dynamic> percentilesMap = Map<String, dynamic>.from(data);
      return percentilesMap.map(
        (key, value) => MapEntry(key, CVAnalysisModel._parseDouble(value) ?? 0.0),
      );
    } catch (e) {
      return {};
    }
  }

  static List<BenchmarkInsightModel> _parseInsights(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> insightsList = List<dynamic>.from(data);
      return insightsList
          .map((item) => BenchmarkInsightModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_score': currentScore,
      'percentile_rank': percentileRank,
      'total_peers': totalPeers,
      'groups': groups,
      'summary': summary,
      'peer_comparisons': peerComparisons,
      'comparison_group': comparisonGroup,
      'section_percentiles': sectionPercentiles,
      'insights': insights.map((i) => i.toJson()).toList(),
      'statistics': statistics,
    };
  }

  String get performanceLevel {
    if (percentileRank >= 90) return 'Top 10%';
    if (percentileRank >= 75) return 'Top 25%';
    if (percentileRank >= 50) return 'Above Average';
    if (percentileRank >= 25) return 'Below Average';
    return 'Bottom 25%';
  }

  BenchmarkingDataModel copyWith({
    String? userId,
    double? currentScore,
    double? percentileRank,
    int? totalPeers,
    List<String>? groups,
    String? summary,
    List<String>? peerComparisons,
    String? comparisonGroup,
    Map<String, double>? sectionPercentiles,
    List<BenchmarkInsightModel>? insights,
    Map<String, dynamic>? statistics,
  }) {
    return BenchmarkingDataModel(
      userId: userId ?? this.userId,
      currentScore: currentScore ?? this.currentScore,
      percentileRank: percentileRank ?? this.percentileRank,
      totalPeers: totalPeers ?? this.totalPeers,
      groups: groups ?? this.groups,
      summary: summary ?? this.summary,
      peerComparisons: peerComparisons ?? this.peerComparisons,
      comparisonGroup: comparisonGroup ?? this.comparisonGroup,
      sectionPercentiles: sectionPercentiles ?? this.sectionPercentiles,
      insights: insights ?? this.insights,
      statistics: statistics ?? this.statistics,
    );
  }
}

class BenchmarkInsightModel {
  final String type;
  final String message;
  final String severity;
  final Map<String, dynamic> data;

  const BenchmarkInsightModel({
    required this.type,
    required this.message,
    required this.severity,
    required this.data,
  });

  factory BenchmarkInsightModel.fromJson(Map<String, dynamic> json) {
    try {
      return BenchmarkInsightModel(
        type: json['type']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        severity: json['severity']?.toString() ?? 'info',
        data: Map<String, dynamic>.from(json['data'] ?? {}),
      );
    } catch (e) {
      throw FormatException('Failed to parse BenchmarkInsightModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'severity': severity,
      'data': data,
    };
  }

  bool get isPositive => severity.toLowerCase() == 'positive';
  bool get isWarning => severity.toLowerCase() == 'warning';
  bool get isNegative => severity.toLowerCase() == 'negative';

  BenchmarkInsightModel copyWith({
    String? type,
    String? message,
    String? severity,
    Map<String, dynamic>? data,
  }) {
    return BenchmarkInsightModel(
      type: type ?? this.type,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      data: data ?? this.data,
    );
  }
}

class AnalysisHistoryModel {
  final List<CVAnalysisModel> analyses;
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;
  final int currentPage;
  final int totalPages;

  const AnalysisHistoryModel({
    required this.analyses,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
    required this.currentPage,
    required this.totalPages,
  });

  factory AnalysisHistoryModel.fromJson(Map<String, dynamic> json) {
    try {
      return AnalysisHistoryModel(
        analyses: _parseAnalyses(json['results']),
        totalCount: json['count'] ?? 0,
        hasNext: json['next'] != null,
        hasPrevious: json['previous'] != null,
        currentPage: json['current_page'] ?? 1,
        totalPages: json['total_pages'] ?? 1,
      );
    } catch (e) {
      throw FormatException('Failed to parse AnalysisHistoryModel: $e');
    }
  }

  static List<CVAnalysisModel> _parseAnalyses(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> analysesList = List<dynamic>.from(data);
      return analysesList
          .map((item) => CVAnalysisModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'results': analyses.map((a) => a.toJson()).toList(),
      'count': totalCount,
      'has_next': hasNext,
      'has_previous': hasPrevious,
      'current_page': currentPage,
      'total_pages': totalPages,
    };
  }

  AnalysisHistoryModel copyWith({
    List<CVAnalysisModel>? analyses,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
    int? currentPage,
    int? totalPages,
  }) {
    return AnalysisHistoryModel(
      analyses: analyses ?? this.analyses,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}