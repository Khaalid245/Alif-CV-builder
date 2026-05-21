import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/analytics_models.dart';

class ScoreTrendChart extends StatelessWidget {
  final TrendAnalysisModel trendAnalysis;
  final bool showDetails;

  const ScoreTrendChart({
    super.key,
    required this.trendAnalysis,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTrendIcon(trendAnalysis.trendDirection),
                  color: _getTrendColor(trendAnalysis.trendDirection),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Score Trend',
                  style: AppTypography.h6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(trendAnalysis.trendDirection).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                  ),
                  child: Text(
                    _formatTrendDirection(trendAnalysis.trendDirection),
                    style: AppTypography.caption.copyWith(
                      color: _getTrendColor(trendAnalysis.trendDirection),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            if (showDetails) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    'Change: ${trendAnalysis.absoluteChange > 0 ? '+' : ''}${trendAnalysis.absoluteChange.toStringAsFixed(1)} points',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Strength: ${_formatTrendStrength(trendAnalysis.trendStrength)}',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.divider,
                        strokeWidth: 1,
                      );
                    },
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
                        reservedSize: 30,
                        interval: _calculateXInterval(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < trendAnalysis.dataPoints.length) {
                            final date = trendAnalysis.dataPoints[index].date;
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormatter.formatShortDate(date),
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
                        interval: 20,
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
                  minX: 0,
                  maxX: (trendAnalysis.dataPoints.length - 1).toDouble(),
                  minY: _getMinY(),
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      color: _getTrendColor(trendAnalysis.trendDirection),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _getTrendColor(trendAnalysis.trendDirection),
                            strokeWidth: 2,
                            strokeColor: AppColors.background,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getTrendColor(trendAnalysis.trendDirection).withOpacity(0.1),
                      ),
                    ),
                    if (trendAnalysis.predictedNextValue != null)
                      _getPredictionLine(),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpots) => Colors.grey[800]!,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < trendAnalysis.dataPoints.length) {
                            final dataPoint = trendAnalysis.dataPoints[index];
                            return LineTooltipItem(
                              '${DateFormatter.formatShortDate(dataPoint.date)}\nScore: ${spot.y.toStringAsFixed(1)}',
                              AppTypography.caption.copyWith(
                                color: AppColors.white,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            if (showDetails && trendAnalysis.predictedNextValue != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Predicted next score: ${trendAnalysis.predictedNextValue!.toStringAsFixed(1)}',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return trendAnalysis.dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  LineChartBarData _getPredictionLine() {
    if (trendAnalysis.predictedNextValue == null || trendAnalysis.dataPoints.isEmpty) {
      return LineChartBarData(spots: []);
    }

    final lastIndex = trendAnalysis.dataPoints.length - 1;
    final lastValue = trendAnalysis.dataPoints.last.value;
    final predictedIndex = lastIndex + 1;

    return LineChartBarData(
      spots: [
        FlSpot(lastIndex.toDouble(), lastValue),
        FlSpot(predictedIndex.toDouble(), trendAnalysis.predictedNextValue!),
      ],
      isCurved: false,
      color: AppColors.primary.withOpacity(0.5),
      barWidth: 2,
      dashArray: [5, 5],
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (index == 1) { // Prediction point
            return FlDotCirclePainter(
              radius: 6,
              color: AppColors.primary.withOpacity(0.5),
              strokeWidth: 2,
              strokeColor: AppColors.primary,
            );
          }
          return FlDotCirclePainter(
            radius: 0,
            color: Colors.transparent,
          );
        },
      ),
    );
  }

  double _getMinY() {
    if (trendAnalysis.dataPoints.isEmpty) return 0;
    final minValue = trendAnalysis.dataPoints
        .map((p) => p.value)
        .reduce((a, b) => a < b ? a : b);
    return (minValue - 10).clamp(0, double.infinity);
  }

  double _getMaxY() {
    if (trendAnalysis.dataPoints.isEmpty) return 100;
    var maxValue = trendAnalysis.dataPoints
        .map((p) => p.value)
        .reduce((a, b) => a > b ? a : b);
    
    if (trendAnalysis.predictedNextValue != null) {
      maxValue = [maxValue, trendAnalysis.predictedNextValue!]
          .reduce((a, b) => a > b ? a : b);
    }
    
    return (maxValue + 10).clamp(0, 100);
  }

  double _calculateXInterval() {
    final dataPointsCount = trendAnalysis.dataPoints.length;
    if (dataPointsCount <= 7) return 1;
    if (dataPointsCount <= 14) return 2;
    if (dataPointsCount <= 30) return 5;
    return 10;
  }

  IconData _getTrendIcon(String direction) {
    switch (direction.toLowerCase()) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      case 'volatile':
        return Icons.show_chart;
      default:
        return Icons.help;
    }
  }

  Color _getTrendColor(String direction) {
    switch (direction.toLowerCase()) {
      case 'improving':
        return AppColors.success;
      case 'declining':
        return AppColors.error;
      case 'stable':
        return AppColors.textSecondary;
      case 'volatile':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTrendDirection(String direction) {
    switch (direction.toLowerCase()) {
      case 'improving':
        return 'Improving';
      case 'declining':
        return 'Declining';
      case 'stable':
        return 'Stable';
      case 'volatile':
        return 'Volatile';
      default:
        return direction;
    }
  }

  String _formatTrendStrength(String strength) {
    switch (strength.toLowerCase()) {
      case 'strong':
        return 'Strong';
      case 'moderate':
        return 'Moderate';
      case 'weak':
        return 'Weak';
      default:
        return strength;
    }
  }
}