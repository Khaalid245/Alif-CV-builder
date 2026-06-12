import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../presentation/providers/cv_intelligence_provider.dart';

/// Displays the user's CV score over time with delta indicators and a trend badge.
/// The chart is powered by [scoreProgressionProvider] which calls the backend
/// `GET /cv/analysis/history/progression/` endpoint.
///
/// Enterprise design goals:
/// - Shows "You improved from 62 → 78" at a glance
/// - Color-coded bars (green/yellow/red) per delta
/// - Trend badge (Improving / Stable / Declining)
/// - Zero dependencies — uses only Flutter built-in widgets
class ScoreProgressionWidget extends ConsumerWidget {
  const ScoreProgressionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionAsync = ref.watch(scoreProgressionProvider);

    return progressionAsync.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final hasData = data['has_data'] as bool? ?? false;
        if (!hasData) return _buildNoHistoryState();

        final snapshots = (data['snapshots'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (snapshots.isEmpty) return _buildNoHistoryState();

        final trend = data['trend'] as String? ?? 'stable';
        final totalImprovement = (data['total_improvement'] as num?)?.toDouble() ?? 0;
        final firstScore = (data['first_score'] as num?)?.toDouble() ?? 0;
        final latestScore = (data['latest_score'] as num?)?.toDouble() ?? 0;
        final totalAnalyses = data['total_analyses'] as int? ?? 0;

        return _buildProgressionCard(
          context,
          snapshots: snapshots,
          trend: trend,
          totalImprovement: totalImprovement,
          firstScore: firstScore,
          latestScore: latestScore,
          totalAnalyses: totalAnalyses,
        );
      },
    );
  }

  // ── Main card ─────────────────────────────────────────────────────────────

  Widget _buildProgressionCard(
    BuildContext context, {
    required List<Map<String, dynamic>> snapshots,
    required String trend,
    required double totalImprovement,
    required double firstScore,
    required double latestScore,
    required int totalAnalyses,
  }) {
    final trendColor = _trendColor(trend);
    final trendIcon = _trendIcon(trend);
    final trendLabel = _trendLabel(trend);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.trendingUp,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score Progression',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$totalAnalyses analysis${totalAnalyses == 1 ? '' : 'es'} total',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Trend badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: trendColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 13, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trendLabel,
                        style: AppTypography.caption.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Summary banner
          if (firstScore != latestScore)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildSummaryBanner(
                  firstScore, latestScore, totalImprovement, trend),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Bar chart
          SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildBarChart(snapshots),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // ── Summary banner ────────────────────────────────────────────────────────

  Widget _buildSummaryBanner(
    double firstScore,
    double latestScore,
    double totalImprovement,
    String trend,
  ) {
    final isImproving = totalImprovement > 0;
    final color = isImproving ? AppColors.success : AppColors.error;
    final sign = isImproving ? '+' : '';
    final verb = isImproving ? 'improved' : 'declined';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isImproving ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: 'You $verb from ',
                  ),
                  TextSpan(
                    text: '${firstScore.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const TextSpan(text: ' → '),
                  TextSpan(
                    text: '${latestScore.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  TextSpan(
                    text:
                        ' ($sign${totalImprovement.toStringAsFixed(1)} pts)',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
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

  // ── Bar chart ─────────────────────────────────────────────────────────────

  Widget _buildBarChart(List<Map<String, dynamic>> snapshots) {
    final scores =
        snapshots.map((s) => (s['score'] as num?)?.toDouble() ?? 0).toList();
    final maxScore = scores.fold<double>(0, (m, s) => s > m ? s : m);
    final minScore = scores.fold<double>(100, (m, s) => s < m ? s : m);
    final range = (maxScore - minScore).clamp(10.0, 100.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth =
            (constraints.maxWidth - (snapshots.length - 1) * 8) / snapshots.length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(snapshots.length, (i) {
            final snapshot = snapshots[i];
            final score = (snapshot['score'] as num?)?.toDouble() ?? 0;
            final delta = (snapshot['score_delta'] as num?)?.toDouble() ?? 0;
            final date = _formatDate(snapshot['analyzed_at'] as String? ?? '');

            // Normalize height (30% min to 100% max)
            final heightFraction = maxScore == minScore
                ? 0.8
                : 0.3 + ((score - minScore) / range) * 0.7;
            final barHeight = constraints.maxHeight * heightFraction;

            // Color based on delta
            final barColor = i == 0
                ? AppColors.primary.withOpacity(0.6)
                : delta > 0
                    ? AppColors.success
                    : delta < 0
                        ? AppColors.error
                        : AppColors.textSecondary;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < snapshots.length - 1 ? 8 : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Delta label (top of bar)
                    if (i > 0 && delta != 0)
                      Text(
                        '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: barColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),

                    const SizedBox(height: 2),

                    // Bar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400 + (i * 80)),
                      curve: Curves.easeOut,
                      width: barWidth,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Score label below bar
                    Text(
                      score.toStringAsFixed(0),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),

                    // Date label
                    Text(
                      date,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ── Empty / skeleton states ───────────────────────────────────────────────

  Widget _buildNoHistoryState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.barChart2,
              size: 40, color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No progression data yet',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Run your first CV analysis to start tracking your score over time.',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _trendColor(String trend) {
    switch (trend) {
      case 'improving':
        return AppColors.success;
      case 'declining':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _trendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return LucideIcons.trendingUp;
      case 'declining':
        return LucideIcons.trendingDown;
      default:
        return LucideIcons.minus;
    }
  }

  String _trendLabel(String trend) {
    switch (trend) {
      case 'improving':
        return 'Improving';
      case 'declining':
        return 'Declining';
      default:
        return 'Stable';
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }
}
