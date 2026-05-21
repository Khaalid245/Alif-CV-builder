import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class BenchmarkingCard extends StatelessWidget {
  final Map<String, dynamic> benchmarkingData;
  final bool isCompact;

  const BenchmarkingCard({
    super.key,
    required this.benchmarkingData,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentScore = (benchmarkingData['current_score'] ?? 0.0).toDouble();
    final percentileRank = (benchmarkingData['percentile_rank'] ?? 0.0).toDouble();
    final totalPeers = benchmarkingData['total_peers'] ?? 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Peer Benchmarking',
                  style: AppTypography.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            if (!isCompact) ...[
              _buildPercentileVisualization(percentileRank),
              const SizedBox(height: AppSpacing.lg),
            ],
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Your Score',
                    currentScore.toStringAsFixed(1),
                    Icons.person,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildMetricCard(
                    'Percentile',
                    '${percentileRank.toStringAsFixed(0)}th',
                    Icons.leaderboard,
                    _getPercentileColor(percentileRank),
                  ),
                ),
              ],
            ),
            
            if (!isCompact) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total Peers',
                      totalPeers.toString(),
                      Icons.group,
                      AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildMetricCard(
                      'Performance',
                      _getPerformanceLabel(percentileRank),
                      Icons.trending_up,
                      _getPercentileColor(percentileRank),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: AppSpacing.md),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getPercentileColor(percentileRank).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPerformanceIcon(percentileRank),
                    color: _getPercentileColor(percentileRank),
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _getPerformanceDescription(percentileRank),
                      style: AppTypography.body2.copyWith(
                        color: _getPercentileColor(percentileRank),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentileVisualization(double percentileRank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Position Among Peers',
          style: AppTypography.body2.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
            border: Border.all(color: AppColors.divider),
          ),
          child: Stack(
            children: [
              // Background
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                ),
              ),
              
              // Progress bar
              FractionallySizedBox(
                widthFactor: percentileRank / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getPercentileColor(percentileRank).withOpacity(0.7),
                        _getPercentileColor(percentileRank),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                  ),
                ),
              ),
              
              // Position indicator
              Positioned(
                left: (percentileRank / 100) * 300 - 12, // Fixed width instead of context
                top: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getPercentileColor(percentileRank),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.white,
                    size: 12,
                  ),
                ),
              ),
              
              // Labels
              Positioned(
                left: 8,
                top: 12,
                child: Text(
                  '0%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 12,
                child: Text(
                  '100%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lower Performers',
              style: AppTypography.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
            Text(
              'You (${percentileRank.toStringAsFixed(0)}%)',
              style: AppTypography.caption.copyWith(
                color: _getPercentileColor(percentileRank),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Top Performers',
              style: AppTypography.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPercentileColor(double percentile) {
    if (percentile >= 90) {
      return AppColors.success;
    } else if (percentile >= 75) {
      return AppColors.primary;
    } else if (percentile >= 50) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _getPerformanceLabel(double percentile) {
    if (percentile >= 90) {
      return 'Excellent';
    } else if (percentile >= 75) {
      return 'Above Average';
    } else if (percentile >= 50) {
      return 'Average';
    } else if (percentile >= 25) {
      return 'Below Average';
    } else {
      return 'Needs Work';
    }
  }

  IconData _getPerformanceIcon(double percentile) {
    if (percentile >= 75) {
      return Icons.star;
    } else if (percentile >= 50) {
      return Icons.thumb_up;
    } else {
      return Icons.trending_up;
    }
  }

  String _getPerformanceDescription(double percentile) {
    if (percentile >= 90) {
      return 'Outstanding! You\'re in the top 10% of all users.';
    } else if (percentile >= 75) {
      return 'Great job! You\'re performing better than most peers.';
    } else if (percentile >= 50) {
      return 'You\'re performing at an average level compared to peers.';
    } else if (percentile >= 25) {
      return 'There\'s room for improvement to reach peer average.';
    } else {
      return 'Focus on improving your CV to catch up with peers.';
    }
  }
}