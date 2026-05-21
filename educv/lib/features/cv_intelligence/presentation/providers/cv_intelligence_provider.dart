import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_client_provider.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/cv_intelligence_repository.dart';
import '../../data/repositories/cv_intelligence_repository_impl.dart';
import '../models/cv_intelligence_models.dart';

// Repository provider
final cvIntelligenceRepositoryProvider = Provider<CVIntelligenceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CVIntelligenceRepositoryImpl(apiClient);
});

// Analysis state
class AnalysisState {
  final CVAnalysisModel? analysis;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const AnalysisState({
    this.analysis,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  AnalysisState copyWith({
    CVAnalysisModel? analysis,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return AnalysisState(
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Analysis provider
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final CVIntelligenceRepository _repository;

  AnalysisNotifier(this._repository) : super(const AnalysisState()) {
    _loadLatestAnalysis();
  }

  Future<void> _loadLatestAnalysis() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final analysis = await _repository.getLatestAnalysis();
      
      state = state.copyWith(
        analysis: analysis,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Handle "no analysis found" gracefully
      final errorMessage = e is AppException ? e.message : e.toString();
      final isNoAnalysisError = errorMessage.toLowerCase().contains('not found') ||
                               errorMessage.toLowerCase().contains('no analysis') ||
                               errorMessage.toLowerCase().contains('404');
      
      state = state.copyWith(
        isLoading: false,
        analysis: null,
        error: isNoAnalysisError ? null : errorMessage,
      );
    }
  }

  Future<void> analyzeCV({Map<String, dynamic>? options}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final analysis = await _repository.analyzeCV(options: options);
      state = state.copyWith(
        analysis: analysis,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<void> refreshAnalysis() async {
    // Cache current state to preserve on failure
    final previousAnalysis = state.analysis;
    
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Try to get existing analysis first (safe read-only operation)
      final analysis = await _repository.getLatestAnalysis();
      
      if (analysis != null) {
        // If analysis exists, update state with fresh data
        state = state.copyWith(
          analysis: analysis,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        // No analysis exists - check if user has CV profile
        final hasCVProfile = await _repository.hasCVProfile();
        
        if (hasCVProfile && previousAnalysis != null) {
          // User has CV and had previous analysis - try to re-analyze
          try {
            final newAnalysis = await _repository.analyzeCV();
            state = state.copyWith(
              analysis: newAnalysis,
              isLoading: false,
              lastUpdated: DateTime.now(),
            );
          } catch (analysisError) {
            // Re-analysis failed, restore previous state with error message
            final errorMessage = analysisError is AppException ? analysisError.message : analysisError.toString();
            
            state = state.copyWith(
              analysis: previousAnalysis, // Preserve existing data
              isLoading: false,
              error: errorMessage,
            );
          }
        } else if (!hasCVProfile && previousAnalysis != null) {
          // User doesn't have CV but had previous analysis - preserve data with message
          state = state.copyWith(
            analysis: previousAnalysis, // Preserve existing data
            isLoading: false,
            error: 'Please create or upload your CV first to refresh analysis.',
          );
        } else {
          // No previous analysis and no current analysis
          state = state.copyWith(
            analysis: null,
            isLoading: false,
            error: null, // No error, just no data
          );
        }
      }
    } catch (e) {
      // Network or other error - preserve existing data
      final errorMessage = e is AppException ? e.message : e.toString();
      
      state = state.copyWith(
        analysis: previousAnalysis, // Preserve existing data
        isLoading: false,
        error: 'Network error: $errorMessage',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return AnalysisNotifier(repository);
});

// Analysis history state
class AnalysisHistoryState {
  final AnalysisHistoryModel? history;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;

  const AnalysisHistoryState({
    this.history,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
  });

  AnalysisHistoryState copyWith({
    AnalysisHistoryModel? history,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
  }) {
    return AnalysisHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Analysis history provider
class AnalysisHistoryNotifier extends StateNotifier<AnalysisHistoryState> {
  final CVIntelligenceRepository _repository;

  AnalysisHistoryNotifier(this._repository) : super(const AnalysisHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(isLoading: true, error: null, currentPage: 1);
      } else if (state.history == null) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final history = await _repository.getAnalysisHistory(
        page: refresh ? 1 : state.currentPage,
      );

      state = state.copyWith(
        history: history,
        isLoading: false,
        currentPage: refresh ? 1 : state.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  Future<void> loadMoreHistory() async {
    if (state.isLoadingMore || state.history?.hasNext != true) return;

    try {
      state = state.copyWith(isLoadingMore: true, error: null);
      
      final nextPage = state.currentPage + 1;
      final newHistory = await _repository.getAnalysisHistory(page: nextPage);
      
      final currentAnalyses = state.history?.analyses ?? [];
      final combinedHistory = state.history?.copyWith(
        analyses: [...currentAnalyses, ...newHistory.analyses],
        hasNext: newHistory.hasNext,
        currentPage: nextPage,
      );

      state = state.copyWith(
        history: combinedHistory,
        isLoadingMore: false,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final analysisHistoryProvider = StateNotifierProvider<AnalysisHistoryNotifier, AnalysisHistoryState>((ref) {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return AnalysisHistoryNotifier(repository);
});

// Recommendations state
class RecommendationsState {
  final List<RecommendationModel> recommendations;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String? selectedPriority;
  final bool includeImplemented;

  const RecommendationsState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.selectedPriority,
    this.includeImplemented = false,
  });

  RecommendationsState copyWith({
    List<RecommendationModel>? recommendations,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    String? selectedPriority,
    bool? includeImplemented,
  }) {
    return RecommendationsState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      includeImplemented: includeImplemented ?? this.includeImplemented,
    );
  }

  List<RecommendationModel> get filteredRecommendations {
    return recommendations.where((rec) {
      if (selectedCategory != null && rec.category != selectedCategory) {
        return false;
      }
      if (selectedPriority != null && rec.priority != selectedPriority) {
        return false;
      }
      if (!includeImplemented && rec.isImplemented) {
        return false;
      }
      return true;
    }).toList();
  }

  List<RecommendationModel> get highPriorityRecommendations {
    return recommendations.where((rec) => rec.isHighPriority && !rec.isImplemented).toList();
  }

  List<String> get availableCategories {
    return recommendations.map((rec) => rec.category).toSet().toList()..sort();
  }

  List<String> get availablePriorities {
    return recommendations.map((rec) => rec.priority).toSet().toList()..sort();
  }
}

// Recommendations provider
class RecommendationsNotifier extends StateNotifier<RecommendationsState> {
  final CVIntelligenceRepository _repository;

  RecommendationsNotifier(this._repository) : super(const RecommendationsState()) {
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final recommendations = await _repository.getRecommendations(
        category: state.selectedCategory,
        priority: state.selectedPriority,
        includeImplemented: state.includeImplemented,
      );
      state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  Future<void> markRecommendationImplemented(String recommendationId) async {
    try {
      await _repository.markRecommendationImplemented(recommendationId);
      
      // Update local state
      final updatedRecommendations = state.recommendations.map((rec) {
        if (rec.id == recommendationId) {
          return rec.copyWith(isImplemented: true);
        }
        return rec;
      }).toList();

      state = state.copyWith(recommendations: updatedRecommendations);
    } catch (e) {
      state = state.copyWith(
        error: e is AppException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  void setFilters({
    String? category,
    String? priority,
    bool? includeImplemented,
  }) {
    state = state.copyWith(
      selectedCategory: category,
      selectedPriority: priority,
      includeImplemented: includeImplemented,
    );
    loadRecommendations();
  }

  void clearFilters() {
    state = state.copyWith(
      selectedCategory: null,
      selectedPriority: null,
      includeImplemented: false,
    );
    loadRecommendations();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final recommendationsProvider = StateNotifierProvider<RecommendationsNotifier, RecommendationsState>((ref) {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return RecommendationsNotifier(repository);
});

// Submission readiness provider
final submissionReadinessProvider = FutureProvider<SubmissionReadinessModel>((ref) async {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return repository.getSubmissionReadiness();
});

// Benchmarking data provider
final benchmarkingDataProvider = FutureProvider.family<BenchmarkingDataModel, String?>((ref, comparisonGroup) async {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return repository.getBenchmarkingData(comparisonGroup: comparisonGroup);
});

// Analysis config provider
final analysisConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return repository.getAnalysisConfig();
});

// Specific analysis provider
final specificAnalysisProvider = FutureProvider.family<CVAnalysisModel, String>((ref, analysisId) async {
  final repository = ref.watch(cvIntelligenceRepositoryProvider);
  return repository.getAnalysisById(analysisId);
});