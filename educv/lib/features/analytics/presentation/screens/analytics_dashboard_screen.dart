import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_overview_card.dart';
import '../widgets/score_trend_chart.dart';
import '../widgets/benchmarking_card.dart';
import '../widgets/completion_statistics_card.dart';
import '../widgets/recent_snapshots_list.dart';
import '../widgets/analytics_filter_bar.dart';
import '../../data/models/analytics_models.dart';
import '../../../cv_intelligence/data/models/cv_intelligence_models.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final provider = context.read<AnalyticsProvider>();
    provider.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showCreateSnapshotDialog(),
            icon: const Icon(Icons.add_chart),
            tooltip: 'Create Snapshot',
          ),
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
            Tab(text: 'Benchmarking', icon: Icon(Icons.compare_arrows)),
            Tab(text: 'Statistics', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(provider),
                _buildTrendsTab(provider),
                _buildBenchmarkingTab(provider),
                _buildStatisticsTab(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AnalyticsProvider provider) {
    switch (provider.state) {
      case AnalyticsState.loading:
        return const AppLoader();
      
      case AnalyticsState.error:
        return AppErrorState(
          message: provider.errorMessage ?? 'Failed to load analytics data',
          onRetry: _loadData,
        );
      
      case AnalyticsState.loaded:
        if (provider.dashboardData == null) {
          return const EmptyState(
            title: 'No Analytics Data',
            message: 'No analytics data available. Create a snapshot to get started.',
            icon: Icons.analytics,
          );
        }
        return _buildOverviewContent(provider);
      
      case AnalyticsState.initial:
        return const AppLoader();
    }
  }

  Widget _buildOverviewContent(AnalyticsProvider provider) {
    final dashboard = provider.dashboardData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsOverviewCard(userSummary: dashboard.userSummary),
          const SizedBox(height: AppSpacing.lg),
          
          if (dashboard.trendAnalysis != null) ...[
            Text(
              'Score Trend (Last 30 Days)',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ScoreTrendChart(trendAnalysis: dashboard.trendAnalysis!),
            const SizedBox(height: AppSpacing.lg),
          ],
          
          if (dashboard.benchmarkingSummary.isNotEmpty) ...[
            Text(
              'Peer Comparison',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BenchmarkingCard(
              benchmarkingData: dashboard.benchmarkingSummary,
              isCompact: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          
          Text(
            'Recent Activity',
            style: AppTypography.h6.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          RecentSnapshotsList(
            snapshots: dashboard.recentSnapshots,
            maxItems: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(AnalyticsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsFilterBar(
            selectedPeriod: provider.trendDays,
            onPeriodChanged: provider.setTrendDays,
            showSnapshotFilters: false,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          if (provider.trendAnalysis != null) ...[
            ScoreTrendChart(
              trendAnalysis: provider.trendAnalysis!,
              showDetails: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTrendInsights(provider.trendAnalysis!),
          ] else ...[
            const EmptyState(
              title: 'No Trend Data',
              message: 'Not enough data points for trend analysis. Create more snapshots to see trends.',
              icon: Icons.trending_up,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenchmarkingTab(AnalyticsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.benchmarkingData != null) ...[
            BenchmarkingCard(
              benchmarkingData: {
                'current_score': provider.benchmarkingData!.percentileRank,
                'percentile_rank': provider.benchmarkingData!.percentileRank,
                'total_peers': provider.benchmarkingData!.statistics['total_peers'] ?? 0,
              },
              isCompact: false,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPeerComparisons(provider.benchmarkingData!),
          ] else ...[
            const EmptyState(
              title: 'No Benchmarking Data',
              message: 'Benchmarking data is not available. This may be due to insufficient peer data.',
              icon: Icons.compare_arrows,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(AnalyticsProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsFilterBar(
            selectedPeriod: provider.statsPeriod,
            onPeriodChanged: provider.setStatsPeriod,
            showSnapshotFilters: false,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          if (provider.completionStats != null) ...[
            CompletionStatisticsCard(
              statistics: provider.completionStats!,
            ),
          ] else ...[
            const EmptyState(
              title: 'No Statistics Data',
              message: 'Platform statistics are not available at the moment.',
              icon: Icons.bar_chart,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendInsights(TrendAnalysisModel trend) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Insights',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Direction',
                    _formatTrendDirection(trend.trendDirection),
                    _getTrendDirectionIcon(trend.trendDirection),
                    _getTrendDirectionColor(trend.trendDirection),
                  ),
                ),
                Expanded(
                  child: _buildInsightItem(
                    'Strength',
                    _formatTrendStrength(trend.trendStrength),
                    Icons.fitness_center,
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Change',
                    '${trend.absoluteChange > 0 ? '+' : ''}${trend.absoluteChange.toStringAsFixed(1)}',
                    Icons.change_circle,
                    trend.absoluteChange > 0 ? AppColors.success : AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildInsightItem(
                    'Volatility',
                    trend.volatilityScore.toStringAsFixed(2),
                    Icons.waves,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            
            if (trend.predictedNextValue != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Predicted Next Score: ${trend.predictedNextValue!.toStringAsFixed(1)}',
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.h6.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildPeerComparisons(BenchmarkingDataModel benchmarking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Peer Comparisons',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            ...benchmarking.insights.map((insight) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _buildComparisonRow(insight),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(BenchmarkInsightModel insight) {
    final severity = insight.severity.toLowerCase();
    final color = severity == 'positive' 
        ? AppColors.success 
        : severity == 'negative' 
            ? AppColors.error 
            : AppColors.textSecondary;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            insight.type,
            style: AppTypography.body2,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            insight.message,
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              severity.toUpperCase(),
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateSnapshotDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Score Snapshot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a new score snapshot to track your current CV performance.'),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Snapshot Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'manual', child: Text('Manual')),
                DropdownMenuItem(value: 'milestone', child: Text('Milestone')),
                DropdownMenuItem(value: 'review', child: Text('Review')),
              ],
              onChanged: (value) {
                // Handle selection
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _createSnapshot(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createSnapshot() async {
    Navigator.of(context).pop();
    
    final provider = context.read<AnalyticsProvider>();
    final success = await provider.createSnapshot(
      snapshotType: 'manual',
      triggerEvent: 'User requested snapshot',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Snapshot created successfully' : 'Failed to create snapshot'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _refreshData() {
    final provider = context.read<AnalyticsProvider>();
    provider.refreshAll();
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

  IconData _getTrendDirectionIcon(String direction) {
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

  Color _getTrendDirectionColor(String direction) {
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

  String _formatMetricName(String metric) {
    return metric
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}