import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';

// CV Intelligence Providers & Models
import '../../../../features/cv_intelligence/presentation/providers/cv_intelligence_provider.dart';
import '../../../../features/cv_intelligence/data/models/cv_intelligence_models.dart';
import '../widgets/benchmarking_card.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    ref.read(analysisProvider.notifier).refreshAnalysis();
    ref.read(recommendationsProvider.notifier).loadRecommendations();
    // Invalidate benchmarking future provider so it re-fetches
    ref.invalidate(benchmarkingDataProvider('all'));
  }

  void _analyzeCV() {
    ref.read(analysisProvider.notifier).analyzeCV();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analyzing your CV...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);
    final recommendationsState = ref.watch(recommendationsProvider);
    final benchmarkingAsyncValue = ref.watch(benchmarkingDataProvider('all'));

    return Scaffold(
      backgroundColor: AppColors.surface, // Clean premium background
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildBody(
                analysisState, recommendationsState, benchmarkingAsyncValue),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: analysisState.isLoading ? null : _analyzeCV,
        backgroundColor: AppColors.primary,
        icon: analysisState.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(LucideIcons.brain, color: Colors.white),
        label: const Text('Analyze CV',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
        title: Row(
          children: [
            const Icon(LucideIcons.brainCircuit,
                color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'CV Intelligence',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh Data',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.divider, height: 1),
      ),
    );
  }

  Widget _buildBody(AnalysisState state, RecommendationsState recsState,
      AsyncValue<BenchmarkingDataModel> benchAsync) {
    if (state.isLoading && state.analysis == null) {
      return const SizedBox(
        height: 400,
        child: Center(child: AppLoader()),
      );
    }

    if (state.error != null && state.analysis == null) {
      return SizedBox(
        height: 400,
        child: AppErrorState(
          message: state.error ?? 'Failed to load CV intelligence data',
          onRetry: _refreshData,
        ),
      );
    }

    if (state.analysis == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: EmptyState(
          title: 'No CV Analysis Found',
          message:
              'Click "Analyze CV" below to generate your first score and get recommendations.',
          icon: LucideIcons.fileSearch,
        ),
      );
    }

    final analysis = state.analysis!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overall Score / Hero
          _buildHeroScoreSection(analysis),
          const SizedBox(height: AppSpacing.xxl),

          // 2. Actionable Recommendations
          _buildSectionHeader(
              'Actionable Recommendations', LucideIcons.listTodo),
          if (recsState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator()))
          else if (recsState.recommendations.isEmpty)
            _buildGlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Text('Great job! No critical issues found.',
                  style: TextStyle(color: AppColors.success)),
            )
          else
            _buildGlassContainer(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _buildRecommendationsList(
                  recsState.highPriorityRecommendations.isNotEmpty
                      ? recsState.highPriorityRecommendations
                      : recsState.recommendations),
            ),
          const SizedBox(height: AppSpacing.xxl),

          // 3. Section Breakdown
          _buildSectionHeader('Section Breakdown', LucideIcons.layers),
          _buildGlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _buildSectionScores(analysis.sectionScores),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 4. Benchmarking
          _buildSectionHeader('Peer Benchmarking', LucideIcons.target),
          benchAsync.when(
            data: (benchData) => _buildGlassContainer(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BenchmarkingCard(benchmarkingData: {
                'summary': benchData.summary,
                'performance_level': benchData.performanceLevel,
                'percentile_rank': benchData.percentileRank,
                'total_participants': benchData.totalPeers,
                'average_score':
                    0.0, // Backend might not provide this directly in flat benchmap
                'top_score': 0.0,
                'user_rank': 0,
              }, isCompact: false),
            ),
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator())),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.error.withOpacity(0.1),
              child: const Text('Could not load benchmarking data.'),
            ),
          ),

          const SizedBox(height: 80), // FAB padding
        ],
      ),
    );
  }

  Widget _buildHeroScoreSection(CVAnalysisModel analysis) {
    Color scoreColor;
    if (analysis.overallScore >= 80) {
      scoreColor = AppColors.success;
    } else if (analysis.overallScore >= 60) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.error;
    }

    return _buildGlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Circular Score
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: analysis.overallScore / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${analysis.overallScore.toInt()}',
                    style: AppTypography.h1.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('/ 100', style: AppTypography.caption),
                ],
              ),
            ],
          ),
          // Readiness Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CV Readiness Score',
                    style:
                        AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    analysis.submissionReadiness.isReady
                        ? 'Your CV is ready for applications!'
                        : 'Needs improvement before applying.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: analysis.submissionReadiness.isReady
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          analysis.submissionReadiness.isReady
                              ? LucideIcons.checkCircle
                              : LucideIcons.alertTriangle,
                          size: 16,
                          color: analysis.submissionReadiness.isReady
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          analysis.submissionReadiness.overallAssessment
                              .toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: analysis.submissionReadiness.isReady
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<RecommendationModel> recs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recs.length > 5 ? 5 : recs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final rec = recs[index];
        final isHighPriority = rec.isHighPriority;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighPriority
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHighPriority ? LucideIcons.alertCircle : LucideIcons.lightbulb,
              color: isHighPriority ? AppColors.error : AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(rec.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(rec.description),
          trailing: rec.actionText.isNotEmpty
              ? TextButton(
                  onPressed: () {
                    // Implementation action
                  },
                  child: Text(rec.actionText),
                )
              : null,
        );
      },
    );
  }

  Widget _buildSectionScores(Map<String, SectionScoreModel> sectionScores) {
    if (sectionScores.isEmpty) {
      return const Text('No section breakdown available.');
    }
    return Column(
      children: sectionScores.entries.map((entry) {
        final section = entry.key;
        final score = entry.value;
        final color = score.isExcellent
            ? AppColors.success
            : score.isGood
                ? AppColors.primary
                : score.isAverage
                    ? AppColors.warning
                    : AppColors.error;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(section.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${score.score.toInt()}/100',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: score.percentage / 100,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer(
      {required Widget child, required EdgeInsets padding}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
