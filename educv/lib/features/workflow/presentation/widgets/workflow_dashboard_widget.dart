import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/workflow_models.dart';

class WorkflowDashboardStatsWidget extends StatelessWidget {
  final WorkflowDashboardModel dashboard;

  const WorkflowDashboardStatsWidget({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workflow Statistics',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildStatsGrid(),
            const SizedBox(height: AppSpacing.lg),
            _buildStateDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard(
          'Total Workflows',
          dashboard.totalInstances.toString(),
          LucideIcons.workflow,
          AppColors.primary,
        ),
        _buildStatCard(
          'Active',
          dashboard.activeInstances.toString(),
          LucideIcons.play,
          AppColors.warning,
        ),
        _buildStatCard(
          'Completed',
          dashboard.completedInstances.toString(),
          LucideIcons.checkCircle,
          AppColors.success,
        ),
        _buildStatCard(
          'Success Rate',
          '${_calculateSuccessRate()}%',
          LucideIcons.trendingUp,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Text(
                value,
                style: AppTypography.headingSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateDistribution() {
    if (dashboard.stateDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State Distribution',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...dashboard.stateDistribution.entries.map((entry) => 
          _buildStateDistributionItem(entry.key, entry.value)
        ),
      ],
    );
  }

  Widget _buildStateDistributionItem(String state, int count) {
    final total = dashboard.totalInstances;
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              state,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 60,
            child: Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateSuccessRate() {
    if (dashboard.totalInstances == 0) return '0.0';
    return ((dashboard.completedInstances / dashboard.totalInstances) * 100)
        .toStringAsFixed(1);
  }
}

class WorkflowInstanceListWidget extends StatelessWidget {
  final List<WorkflowInstanceModel> instances;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final Function(WorkflowInstanceModel)? onInstanceTap;

  const WorkflowInstanceListWidget({
    super.key,
    required this.instances,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onInstanceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (instances.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workflow Instances',
          style: AppTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...instances.map((instance) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: WorkflowInstanceCard(
            instance: instance,
            onTap: () => onInstanceTap?.call(instance),
          ),
        )),
        if (hasMore && onLoadMore != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextButton.icon(
                onPressed: isLoading ? null : onLoadMore,
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.chevronDown),
                label: Text(isLoading ? 'Loading...' : 'Load More'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.workflow,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No Workflow Instances',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No workflow instances have been created yet.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WorkflowInstanceCard extends StatelessWidget {
  final WorkflowInstanceModel instance;
  final VoidCallback? onTap;

  const WorkflowInstanceCard({
    super.key,
    required this.instance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStateIndicator(),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instance.workflowConfig.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Object ID: ${instance.objectId}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Started ${_formatDateTime(instance.startedAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated ${_formatDateTime(instance.updatedAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateIndicator() {
    final color = _getStateColor();
    final icon = _getStateIcon();

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildStatusChip() {
    final color = _getStateColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        instance.currentState.name,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStateColor() {
    switch (instance.currentState.stateType.toLowerCase()) {
      case 'initial':
        return AppColors.info;
      case 'intermediate':
        return AppColors.warning;
      case 'final':
        return AppColors.success;
      case 'terminal':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStateIcon() {
    switch (instance.currentState.stateType.toLowerCase()) {
      case 'initial':
        return LucideIcons.play;
      case 'intermediate':
        return LucideIcons.clock;
      case 'final':
        return LucideIcons.checkCircle;
      case 'terminal':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}