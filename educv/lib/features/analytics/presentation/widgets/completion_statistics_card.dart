import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/analytics_models.dart';

class CompletionStatisticsCard extends StatelessWidget {
  final CompletionStatisticsModel statistics;

  const CompletionStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Statistics',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Overview metrics
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    statistics.totalUsers.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Avg Completion',
                    '${statistics.averageCompletion.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Score',
                    statistics.averageScore.toStringAsFixed(1),
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Ready to Submit',
                    '${statistics.submissionReadyPercentage.toStringAsFixed(1)}%',
                    Icons.send,
                    AppColors.error,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Score distribution chart
            if (statistics.scoreDistribution.isNotEmpty) ...[
              Text(
                'Score Distribution',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxScoreCount().toDouble(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.grey[800]!,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final range = _getScoreRanges()[groupIndex];
                          return BarTooltipItem(
                            '$range\n${rod.toY.toInt()} users',
                            AppTypography.caption.copyWith(
                              color: AppColors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final ranges = _getScoreRanges();
                            final index = value.toInt();
                            if (index >= 0 && index < ranges.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  ranges[index],
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toInt().toString(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                    barGroups: _getBarGroups(),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
            ],
            
            // Section averages
            if (statistics.sectionAverages.isNotEmpty) ...[
              Text(
                'Section Performance',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              ...statistics.sectionAverages.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildSectionBar(entry.key, entry.value),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.h6.copyWith(
              fontWeight: FontWeight.w700,
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

  Widget _buildSectionBar(String section, double average) {
    final percentage = (average / 100).clamp(0.0, 1.0);
    final color = _getSectionColor(average);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatSectionName(section),
              style: AppTypography.body2,
            ),
            Text(
              average.toStringAsFixed(1),
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.surface,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  List<String> _getScoreRanges() {
    return ['0-20', '21-40', '41-60', '61-80', '81-100'];
  }

  List<BarChartGroupData> _getBarGroups() {
    final ranges = _getScoreRanges();
    return ranges.asMap().entries.map((entry) {
      final index = entry.key;
      final range = entry.value;
      final count = statistics.scoreDistribution[range] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: _getBarColor(index),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(int index) {
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.textSecondary,
      AppColors.primary,
      AppColors.success,
    ];
    return colors[index % colors.length];
  }

  Color _getSectionColor(double average) {
    if (average >= 80) {
      return AppColors.success;
    } else if (average >= 60) {
      return AppColors.primary;
    } else if (average >= 40) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatSectionName(String section) {
    return section
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  int _getMaxScoreCount() {
    if (statistics.scoreDistribution.isEmpty) return 10;
    return statistics.scoreDistribution.values
        .reduce((a, b) => a > b ? a : b);
  }
}