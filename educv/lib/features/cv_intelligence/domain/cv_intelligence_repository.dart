import '../presentation/models/cv_intelligence_models.dart';

abstract class CVIntelligenceRepository {
  Future<CVAnalysisModel?> getLatestAnalysis();
  Future<CVAnalysisModel> analyzeCV({Map<String, dynamic>? options});
  Future<AnalysisHistoryModel> getAnalysisHistory({int page = 1});
  Future<List<RecommendationModel>> getRecommendations({
    String? category,
    String? priority,
    bool includeImplemented = false,
  });
  Future<void> markRecommendationImplemented(String recommendationId);
  Future<SubmissionReadinessModel> getSubmissionReadiness();
  Future<BenchmarkingDataModel> getBenchmarkingData({String? comparisonGroup});
  Future<Map<String, dynamic>> getAnalysisConfig();
  Future<CVAnalysisModel> getAnalysisById(String analysisId);
  Future<bool> hasCVProfile();
  Future<String> exportAnalysisReport();
}