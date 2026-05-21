import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../analytics/presentation/widgets/benchmarking_card.dart';
import '../providers/cv_intelligence_provider.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/submission_readiness_widget.dart';
import '../../data/models/cv_intelligence_models.dart';

class CVIntelligenceScreen extends HookConsumerWidget {
  const CVIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 4);
    final analysisState = ref.watch(analysisProvider);
    final recommendationsState = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Intelligence'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Sections'),
                Tab(text: 'Recommendations'),
                Tab(text: 'History'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showAnalysisOptions(context, ref),
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Analysis Settings',
          ),
          IconButton(
            onPressed: () => _refreshAnalysis(ref, context),
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh Analysis',
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildOverviewTab(context, ref, analysisState),
          _buildSectionsTab(context, ref, analysisState),
          _buildRecommendationsTab(context, ref, recommendationsState),
          _buildHistoryTab(context, ref),
        ],
      ),
      floatingActionButton: analysisState.analysis == null && !analysisState.isLoading
          ? FloatingActionButton.extended(
              onPressed: () => _analyzeCV(context, ref),
              icon: const Icon(LucideIcons.brain),
              label: const Text('Analyze CV'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildOverviewTab(BuildContext context, WidgetRef ref, AnalysisState state) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(analysisProvider.notifier).refreshAnalysis(),
      );
    }

    if (state.analysis == null) {
      return _buildEmptyAnalysisState(context, ref);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallScoreCard(state.analysis!),
          const SizedBox(height: AppSpacing.lg),
          _buildSubmissionReadinessSection(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildBenchmarkingSection(context, ref),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickActionsSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionsTab(BuildContext context, WidgetRef ref, AnalysisState state) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(analysisProvider.notifier).refreshAnalysis(),
      );
    }

    if (state.analysis == null) {
      return _buildEmptyAnalysisState(context, ref);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section Scores',
            style: AppTypography.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...state.analysis!.sectionScores.entries.map((entry) =>
            SectionScoreCard(
              sectionName: entry.key,
              sectionScore: entry.value,
              onTap: () => _showSectionDetails(context, entry.key, entry.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(BuildContext context, WidgetRef ref, RecommendationsState state) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(recommendationsProvider.notifier).loadRecommendations(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendationsHeader(context, ref, state),
          const SizedBox(height: AppSpacing.md),
          RecommendationsList(
            recommendations: state.filteredRecommendations,
            onRecommendationImplemented: (id) => _markRecommendationImplemented(context, ref, id),
            onRecommendationAction: (recommendation) => _handleRecommendationAction(recommendation),
            showFilters: true,
            selectedCategory: state.selectedCategory,
            selectedPriority: state.selectedPriority,
            onCategoryChanged: (category) => ref.read(recommendationsProvider.notifier).setFilters(category: category),
            onPriorityChanged: (priority) => ref.read(recommendationsProvider.notifier).setFilters(priority: priority),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(analysisHistoryProvider);

    if (historyState.isLoading) {
      return const Center(child: AppLoader());
    }

    if (historyState.error != null) {
      return AppErrorState(
        message: historyState.error!,
        onRetry: () => ref.read(analysisHistoryProvider.notifier).loadHistory(refresh: true),
      );
    }

    if (historyState.history?.analyses.isEmpty ?? true) {
      return _buildEmptyHistoryState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(analysisHistoryProvider.notifier).loadHistory(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: historyState.history!.analyses.length + (historyState.history!.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == historyState.history!.analyses.length) {
            return _buildLoadMoreButton(ref, historyState);
          }

          final analysis = historyState.history!.analyses[index];
          return _buildHistoryItem(context, analysis);
        },
      ),
    );
  }

  Widget _buildEmptyAnalysisState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.brain,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Analysis Yet',
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Get intelligent insights about your CV by running an analysis.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _analyzeCV(context, ref),
              icon: const Icon(LucideIcons.brain),
              label: const Text('Analyze My CV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallScoreCard(analysis) {
    return ScoreDisplayWidget(
      score: analysis.overallScore,
      maxScore: 100,
      title: 'Overall CV Score',
      subtitle: 'Based on comprehensive analysis',
      showPercentage: true,
      animated: true,
    );
  }

  Widget _buildSubmissionReadinessSection(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final readinessAsync = ref.watch(submissionReadinessProvider);
        
        return readinessAsync.when(
          data: (readiness) => SubmissionReadinessWidget(
            readiness: readiness,
            onImprove: () => _showImprovementSuggestions(context, readiness),
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: AppLoader()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Failed to load submission readiness: $error',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenchmarkingSection(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final benchmarkingAsync = ref.watch(benchmarkingDataProvider(null));
        
        return benchmarkingAsync.when(
          data: (benchmarking) {
            // Convert BenchmarkingDataModel to the format expected by BenchmarkingCard
            final benchmarkingData = {
              'current_score': benchmarking.currentScore,
              'percentile_rank': benchmarking.percentileRank,
              'total_peers': benchmarking.totalPeers,
              'performance_level': benchmarking.performanceLevel,
              'user_rank': benchmarking.statistics['user_rank'] ?? 0,
              'average_score': benchmarking.statistics['average_score'] ?? 0.0,
              'top_score': benchmarking.statistics['top_score'] ?? 0.0,
              'comparison_group': benchmarking.comparisonGroup,
              'insights': benchmarking.insights.map((insight) => insight.message).toList(),
            };
            
            return BenchmarkingCard(
              benchmarkingData: benchmarkingData,
              isCompact: false,
            );
          },
          loading: () => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Peer Benchmarking',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Center(child: AppLoader()),
                ],
              ),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.trendingUp,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Peer Benchmarking',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Benchmarking data will be available after your first CV analysis.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _analyzeCV(context, ref),
                    icon: const Icon(LucideIcons.refreshCw),
                    label: const Text('Re-analyze'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportAnalysis(context, ref),
                    icon: const Icon(LucideIcons.download),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsHeader(BuildContext context, WidgetRef ref, RecommendationsState state) {
    final highPriorityCount = state.highPriorityRecommendations.length;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendations',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (highPriorityCount > 0)
                Text(
                  '$highPriorityCount high priority items',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        if (state.recommendations.isNotEmpty)
          TextButton.icon(
            onPressed: () => ref.read(recommendationsProvider.notifier).clearFilters(),
            icon: const Icon(LucideIcons.x, size: 16),
            label: const Text('Clear Filters'),
          ),
      ],
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.history,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Analysis History',
              style: AppTypography.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your analysis history will appear here.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(WidgetRef ref, AnalysisHistoryState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: AppLoader()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: OutlinedButton(
        onPressed: () => ref.read(analysisHistoryProvider.notifier).loadMoreHistory(),
        child: const Text('Load More'),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            '${analysis.overallScore.toStringAsFixed(0)}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Analysis ${analysis.analyzedAt.day}/${analysis.analyzedAt.month}/${analysis.analyzedAt.year}',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${analysis.recommendations.length} recommendations',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => _viewAnalysisDetails(context, analysis.id),
      ),
    );
  }

  // Action methods
  Future<void> _analyzeCV(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(analysisProvider.notifier).analyzeCV();
      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'CV analysis completed successfully!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to analyze CV: ${e.toString()}',
        );
      }
    }
  }

  void _refreshAnalysis(WidgetRef ref, BuildContext context) async {
    try {
      // Clear any existing errors first
      ref.read(analysisProvider.notifier).clearError();
      ref.read(recommendationsProvider.notifier).clearError();
      
      // Show loading feedback
      SnackbarHelper.showInfo(
        context,
        'Refreshing analysis data...',
      );
      
      // Refresh analysis data
      await ref.read(analysisProvider.notifier).refreshAnalysis();
      
      // Check if refresh was successful
      final analysisState = ref.read(analysisProvider);
      
      if (analysisState.error != null) {
        // Show error but don't clear existing data
        if (context.mounted) {
          SnackbarHelper.showError(
            context,
            analysisState.error!,
          );
        }
      } else if (analysisState.analysis != null) {
        // Success - refresh dependent data
        ref.read(recommendationsProvider.notifier).loadRecommendations();
        ref.invalidate(submissionReadinessProvider);
        ref.invalidate(benchmarkingDataProvider(null));
        ref.read(analysisHistoryProvider.notifier).loadHistory(refresh: true);
        
        if (context.mounted) {
          SnackbarHelper.showSuccess(
            context,
            'Analysis data refreshed successfully!',
          );
        }
      } else {
        // No analysis data available
        if (context.mounted) {
          SnackbarHelper.showInfo(
            context,
            'No analysis data found. Please analyze your CV first.',
          );
        }
      }
      
    } catch (e) {
      // Additional error handling
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to refresh: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _markRecommendationImplemented(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(recommendationsProvider.notifier).markRecommendationImplemented(id);
      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Recommendation marked as implemented!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to update recommendation: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _handleRecommendationAction(recommendation) async {
    if (recommendation.actionUrl != null) {
      final uri = Uri.parse(recommendation.actionUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  void _showSectionDetails(BuildContext context, String sectionName, sectionScore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionName.split('_').map((word) => 
                  word[0].toUpperCase() + word.substring(1).toLowerCase()
                ).join(' '),
                style: AppTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ScoreDisplayWidget(
                      score: sectionScore.score,
                      maxScore: sectionScore.maxScore,
                      title: 'Section Score',
                      animated: false,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (sectionScore.strengths.isNotEmpty) ...[
                      _buildDetailSection('Strengths', sectionScore.strengths, AppColors.success),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (sectionScore.weaknesses.isNotEmpty) ...[
                      _buildDetailSection('Weaknesses', sectionScore.weaknesses, AppColors.error),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (sectionScore.suggestions.isNotEmpty)
                      _buildDetailSection('Suggestions', sectionScore.suggestions, AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item,
                  style: AppTypography.bodyMedium.copyWith(
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _showAnalysisOptions(BuildContext context, WidgetRef ref) {
    // Implementation for analysis options dialog
  }

  void _showImprovementSuggestions(BuildContext context, readiness) {
    // Implementation for improvement suggestions dialog
  }

  void _exportAnalysis(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      SnackbarHelper.showInfo(
        context,
        'Generating PDF report...',
      );

      // Export the analysis
      final repository = ref.read(cvIntelligenceRepositoryProvider);
      final filePath = await repository.exportAnalysisReport();

      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Analysis report exported successfully!',
        );

        // Show dialog with option to open file
        _showExportSuccessDialog(context, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to export analysis: ${e.toString()}',
        );
      }
    }
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your CV analysis report has been saved to:'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
              ),
              child: Text(
                filePath,
                style: AppTypography.bodySmall.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openFile(filePath);
            },
            child: const Text('Open File'),
          ),
        ],
      ),
    );
  }

  void _openFile(String filePath) async {
    try {
      // This would require a package like open_file or url_launcher
      // For now, we'll just show the path
      // await OpenFile.open(filePath);
    } catch (e) {
      // Handle error opening file
    }
  }

  void _viewAnalysisDetails(BuildContext context, String analysisId) {
    // Implementation for viewing specific analysis details
  }
}

class SectionScoreCard extends StatelessWidget {
  final String sectionName;
  final SectionScoreModel sectionScore;
  final VoidCallback? onTap;

  const SectionScoreCard({
    super.key,
    required this.sectionName,
    required this.sectionScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatSectionName(sectionName),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreDescription(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sectionScore.percentage.toStringAsFixed(0)}%',
                    style: AppTypography.headingSmall.copyWith(
                      color: _getScoreColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 4,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: AppColors.surface,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: sectionScore.percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: _getScoreColor(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatSectionName(String name) {
    return name.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  String _getScoreDescription() {
    if (sectionScore.isExcellent) return 'Excellent';
    if (sectionScore.isGood) return 'Good';
    if (sectionScore.isAverage) return 'Average';
    return 'Needs Improvement';
  }

  Color _getScoreColor() {
    if (sectionScore.isExcellent) return AppColors.success;
    if (sectionScore.isGood) return AppColors.primary;
    if (sectionScore.isAverage) return AppColors.warning;
    return AppColors.error;
  }
}