import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../router/app_router.dart';
import '../providers/cv_intelligence_provider.dart';
import '../widgets/submission_readiness_widget.dart';

class CVIntelligenceSummaryWidget extends ConsumerWidget {
  const CVIntelligenceSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.md),
            _buildContent(context, ref, analysisState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            LucideIcons.brain,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CV Intelligence',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'AI-powered insights for your CV',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.cvIntelligence),
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AnalysisState state) {
    if (state.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: AppLoader()),
      );
    }

    if (state.analysis == null) {
      return _buildEmptyState(context, ref);
    }

    return _buildAnalysisSummary(context, ref, state.analysis!);
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Icon(
          LucideIcons.brain,
          size: 48,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'No Analysis Yet',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Get AI-powered insights about your CV',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _analyzeCV(context, ref),
            icon: const Icon(LucideIcons.brain, size: 16),
            label: const Text('Analyze CV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSummary(BuildContext context, WidgetRef ref, analysis) {
    final highPriorityRecommendations = ref.watch(recommendationsProvider
        .select((state) => state.highPriorityRecommendations.length));

    return Column(
      children: [
        // Overall Score
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Score',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getScoreLabel(analysis.overallScore),
                    style: AppTypography.bodySmall.copyWith(
                      color: _getScoreColor(analysis.overallScore),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getScoreColor(analysis.overallScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${analysis.overallScore.toStringAsFixed(0)}%',
                style: AppTypography.bodyMedium.copyWith(
                  color: _getScoreColor(analysis.overallScore),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Progress Bar
        LinearProgressIndicator(
          value: analysis.overallScore / 100,
          backgroundColor: AppColors.surface,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getScoreColor(analysis.overallScore),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Submission Readiness
        Consumer(
          builder: (context, ref, child) {
            final readinessAsync = ref.watch(submissionReadinessProvider);
            return readinessAsync.when(
              data: (readiness) => ReadinessStatusBadge(
                readiness: readiness,
                compact: true,
              ),
              loading: () => const SizedBox(
                height: 24,
                child: AppLoader(),
              ),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        ),

        // High Priority Recommendations
        if (highPriorityRecommendations > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.alertTriangle,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '$highPriorityRecommendations high priority recommendations',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _analyzeCV(context, ref),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Re-analyze'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.cvIntelligence),
                icon: const Icon(LucideIcons.eye, size: 16),
                label: const Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.primary;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Average';
    return 'Needs Work';
  }

  Future<void> _analyzeCV(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(analysisProvider.notifier).analyzeCV();
    } catch (e) {
      // Error handling is done in the provider
    }
  }
}