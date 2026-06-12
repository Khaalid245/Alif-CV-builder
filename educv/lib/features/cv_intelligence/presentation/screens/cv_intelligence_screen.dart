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
import '../../../cv/presentation/providers/cv_provider.dart';
import '../../../cv/presentation/widgets/target_role_picker.dart';
import '../providers/cv_intelligence_provider.dart';
import '../widgets/score_display_widget.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/submission_readiness_widget.dart';
import '../widgets/score_progression_widget.dart';
import '../widgets/cv_2026_standards_card.dart';
import '../../data/models/cv_intelligence_models.dart';

class CVIntelligenceScreen extends HookConsumerWidget {
  const CVIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 4);
    final analysisState = ref.watch(analysisProvider);
    final recommendationsState = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryLight,
                AppColors.primaryDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x3310B981),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.brainCircuit, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'CV Intelligence',
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _showAnalysisOptions(context, ref),
                        icon: const Icon(LucideIcons.settings,
                            color: Colors.white),
                        tooltip: 'Analysis Settings',
                      ),
                      IconButton(
                        onPressed: () => _refreshAnalysis(ref, context),
                        icon: const Icon(LucideIcons.refreshCw,
                            color: Colors.white),
                        tooltip: 'Refresh Analysis',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: TabBar(
                      controller: tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelStyle: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
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
              ],
            ),
          ),
        ),
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
      floatingActionButton:
          analysisState.analysis == null && !analysisState.isLoading
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

  Widget _buildOverviewTab(
      BuildContext context, WidgetRef ref, AnalysisState state) {
    if (state.isLoading && state.analysis == null) {
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

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2026 AI Educational Card
              const CV2026StandardsCard(),
              const SizedBox(height: AppSpacing.lg),
              // Role picker — always shown; collapses gracefully if no roles loaded
              _buildTargetRolePicker(context, ref, state),
              const SizedBox(height: AppSpacing.lg),
              _buildOverallScoreCard(state.analysis!),
              const SizedBox(height: AppSpacing.lg),
              _buildSubmissionReadinessSection(context, ref),
              const SizedBox(height: AppSpacing.lg),
              _buildBenchmarkingSection(context, ref),
              const SizedBox(height: AppSpacing.lg),
              _buildEnterpriseMetricsSection(state.analysis!),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickActionsSection(context, ref),
            ],
          ),
        ),
        if (state.isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.transparent,
              child: const LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionsTab(
      BuildContext context, WidgetRef ref, AnalysisState state) {
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
          ...state.analysis!.sectionScores.entries.map(
            (entry) => SectionScoreCard(
              sectionName: entry.key,
              sectionScore: entry.value,
              onTap: () => _showSectionDetails(context, entry.key, entry.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(
      BuildContext context, WidgetRef ref, RecommendationsState state) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () =>
            ref.read(recommendationsProvider.notifier).loadRecommendations(),
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
            onRecommendationImplemented: (id) =>
                _markRecommendationImplemented(context, ref, id),
            onRecommendationAction: (recommendation) =>
                _handleRecommendationAction(recommendation),
            showFilters: true,
            selectedCategory: state.selectedCategory,
            selectedPriority: state.selectedPriority,
            onCategoryChanged: (category) => ref
                .read(recommendationsProvider.notifier)
                .setFilters(category: category),
            onPriorityChanged: (priority) => ref
                .read(recommendationsProvider.notifier)
                .setFilters(priority: priority),
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
        onRetry: () => ref
            .read(analysisHistoryProvider.notifier)
            .loadHistory(refresh: true),
      );
    }

    if (historyState.history?.analyses.isEmpty ?? true) {
      return _buildEmptyHistoryState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(analysisHistoryProvider.notifier).loadHistory(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        // +1 for the progression chart header, +1 for the load-more button
        itemCount: historyState.history!.analyses.length +
            (historyState.history!.hasNext ? 2 : 1),
        itemBuilder: (context, index) {
          // First item: score progression chart
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: ScoreProgressionWidget(),
            );
          }

          final adjustedIndex = index - 1;

          if (adjustedIndex == historyState.history!.analyses.length) {
            return _buildLoadMoreButton(ref, historyState);
          }

          final analysis = historyState.history!.analyses[adjustedIndex];
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

  Widget _buildTargetRolePicker(
      BuildContext context, WidgetRef ref, AnalysisState state) {
    // Read current target role from the cv profile
    final profileAsync = ref.watch(cvProfileProvider);
    final currentRole = profileAsync.whenOrNull<Map<String, dynamic>?>(
      data: (profile) {
        if (profile == null) return null;
        final roleData = profile.targetRole;
        return roleData;
      },
    );

    return TargetRolePicker(currentRole: currentRole);
  }

  Widget _buildOverallScoreCard(analysis) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: ScoreDisplayWidget(
        score: analysis.overallScore,
        maxScore: 100,
        title: 'Overall CV Score',
        subtitle: 'Enterprise AI Analysis',
        showPercentage: true,
        animated: true,
      ),
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
          loading: () => Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Padding(
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
        // ── Role-aware benchmarking ───────────────────────────────────────────
        // If the user has a target role, compare against peers targeting the
        // same role.  Otherwise fall back to the whole-platform comparison.
        final profileAsync = ref.watch(cvProfileProvider);
        final targetRole = profileAsync.whenOrNull<Map<String, dynamic>?>(
          data: (p) => p?.targetRole,
        );
        final roleName = targetRole?['name'] as String?;
        final comparisonGroup = roleName != null ? 'role' : null;

        final benchmarkingAsync =
            ref.watch(benchmarkingDataProvider(comparisonGroup));

        return benchmarkingAsync.when(
          data: (benchmarking) {
            final benchmarkingData = {
              'current_score': benchmarking.currentScore,
              'percentile_rank': benchmarking.percentileRank,
              'total_peers': benchmarking.totalPeers,
              'performance_level': benchmarking.performanceLevel,
              'user_rank': benchmarking.statistics['user_rank'] ?? 0,
              'average_score': benchmarking.statistics['average_score'] ?? 0.0,
              'top_score': benchmarking.statistics['top_score'] ?? 0.0,
              'comparison_group': benchmarking.comparisonGroup,
              // Surface role name so the card can show "vs Software Engineers"
              'role_name': roleName,
              'insights': benchmarking.insights.map((i) => i.message).toList(),
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
                      const Icon(
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
                      const Icon(
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

  Widget _buildEnterpriseMetricsSection(CVAnalysisModel analysis) {
    final atsScore = analysis.metadata['ats_parsability_score'];
    final impactScore = analysis.metadata['impact_score'];

    if (atsScore == null && impactScore == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.cpu,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Enterprise AI Metrics',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (atsScore != null)
                  Expanded(
                    child: _buildEnterpriseMetricCard(
                      'ATS Parsability',
                      atsScore.toString(),
                      LucideIcons.fileSearch,
                      _getMetricColor(atsScore),
                    ),
                  ),
                if (atsScore != null && impactScore != null)
                  const SizedBox(width: AppSpacing.md),
                if (impactScore != null)
                  Expanded(
                    child: _buildEnterpriseMetricCard(
                      'Impact Score',
                      impactScore.toString(),
                      LucideIcons.zap,
                      _getMetricColor(impactScore),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMetricColor(dynamic scoreValue) {
    final score = double.tryParse(scoreValue.toString()) ?? 0;
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildEnterpriseMetricCard(
      String title, String score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score,
                style: AppTypography.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '/100',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
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
                  child: ElevatedButton.icon(
                    onPressed: () => _analyzeCV(context, ref),
                    icon: const Icon(LucideIcons.refreshCw, size: 18),
                    label: const Text('Re-analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportAnalysis(context, ref),
                    icon: const Icon(LucideIcons.download, size: 18),
                    label: const Text('Export PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsHeader(
      BuildContext context, WidgetRef ref, RecommendationsState state) {
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
            onPressed: () =>
                ref.read(recommendationsProvider.notifier).clearFilters(),
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
        onPressed: () =>
            ref.read(analysisHistoryProvider.notifier).loadMoreHistory(),
        child: const Text('Load More'),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, analysis) {
    // ── Read diff_from_previous from metadata (populated by Rec 3) ───────────
    final diff =
        (analysis.metadata['diff_from_previous'] as Map<String, dynamic>?) ??
            {};
    final isFirst = diff['is_first_analysis'] as bool? ?? diff.isEmpty;
    final scoreDelta = (diff['score_delta'] as num?)?.toDouble() ?? 0;
    final resolvedCount = (diff['resolved_issues'] as List?)?.length ?? 0;
    final newCount = (diff['new_issues'] as List?)?.length ?? 0;
    final improvedSections =
        (diff['improved_sections'] as Map?)?.keys.toList() ?? [];
    final regressedSections =
        (diff['regressed_sections'] as Map?)?.keys.toList() ?? [];

    // Grade colour
    final score = analysis.overallScore;
    final scoreColor = score >= 85
        ? AppColors.success
        : score >= 70
            ? AppColors.primary
            : score >= 55
                ? const Color(0xFFF59E0B) // amber
                : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _viewAnalysisDetails(context, analysis.id),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────
              Row(
                children: [
                  // Score badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scoreColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        score.toStringAsFixed(0),
                        style: AppTypography.bodyMedium.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${analysis.analyzedAt.day}/${analysis.analyzedAt.month}/${analysis.analyzedAt.year}  '
                          '${analysis.analyzedAt.hour.toString().padLeft(2, '0')}:'
                          '${analysis.analyzedAt.minute.toString().padLeft(2, '0')}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${analysis.recommendations.length} recommendation${analysis.recommendations.length == 1 ? '' : 's'}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score delta / baseline badge
                  if (isFirst)
                    _diffChip('Baseline', const Color(0xFF6366F1),
                        const Color(0xFFEEF2FF))
                  else if (scoreDelta > 0)
                    _diffChip('+${scoreDelta.toStringAsFixed(0)} pts',
                        AppColors.success, AppColors.success.withOpacity(0.1))
                  else if (scoreDelta < 0)
                    _diffChip('${scoreDelta.toStringAsFixed(0)} pts',
                        AppColors.error, AppColors.error.withOpacity(0.1))
                  else
                    _diffChip('No change', AppColors.textSecondary,
                        AppColors.textSecondary.withOpacity(0.08)),

                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronRight,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),

              // ── Diff narrative (hidden for first analysis) ──────────
              if (!isFirst &&
                  (resolvedCount > 0 ||
                      newCount > 0 ||
                      improvedSections.isNotEmpty ||
                      regressedSections.isNotEmpty)) ...[
                const SizedBox(height: AppSpacing.sm),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (resolvedCount > 0)
                      _narrativeTag(
                          '✓ $resolvedCount fixed', AppColors.success),
                    if (newCount > 0)
                      _narrativeTag(
                          '⚠ $newCount new issue${newCount == 1 ? '' : 's'}',
                          AppColors.error),
                    for (final s in improvedSections.take(2))
                      _narrativeTag('↑ ${_sectionLabel(s)}', AppColors.primary),
                    for (final s in regressedSections.take(2))
                      _narrativeTag(
                          '↓ ${_sectionLabel(s)}', const Color(0xFFF59E0B)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _diffChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _narrativeTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _sectionLabel(String key) {
    const labels = {
      'profile': 'Profile',
      'experience': 'Experience',
      'education': 'Education',
      'skills': 'Skills',
      'projects': 'Projects',
    };
    return labels[key] ?? key[0].toUpperCase() + key.substring(1);
  }

  // Action methods
  Future<void> _analyzeCV(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(analysisProvider.notifier).analyzeCV();

      // Invalidate ALL dependent providers so every tab reflects the new analysis
      ref.invalidate(scoreProgressionProvider);
      ref.read(analysisHistoryProvider.notifier).loadHistory(refresh: true);
      ref.read(recommendationsProvider.notifier).loadRecommendations();
      ref.invalidate(submissionReadinessProvider);
      ref.invalidate(benchmarkingDataProvider(null));

      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'CV analysis completed! Your score has been updated.',
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
        ref.invalidate(
            scoreProgressionProvider); // Refresh score timeline chart

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

  Future<void> _markRecommendationImplemented(
      BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref
          .read(recommendationsProvider.notifier)
          .markRecommendationImplemented(id);
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

  void _showSectionDetails(
      BuildContext context, String sectionName, sectionScore) {
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
                sectionName
                    .split('_')
                    .map((word) =>
                        word[0].toUpperCase() + word.substring(1).toLowerCase())
                    .join(' '),
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
                      _buildDetailSection('Strengths', sectionScore.strengths,
                          AppColors.success),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (sectionScore.weaknesses.isNotEmpty) ...[
                      _buildDetailSection('Weaknesses', sectionScore.weaknesses,
                          AppColors.error),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (sectionScore.suggestions.isNotEmpty)
                      _buildDetailSection('Suggestions',
                          sectionScore.suggestions, AppColors.primary),
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
                const Icon(
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
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
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
