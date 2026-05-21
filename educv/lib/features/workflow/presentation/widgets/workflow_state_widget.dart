import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/workflow_models.dart';

class WorkflowStateWidget extends StatelessWidget {
  final WorkflowInstanceModel workflow;
  final bool showDetails;
  final VoidCallback? onTap;

  const WorkflowStateWidget({
    super.key,
    required this.workflow,
    this.showDetails = true,
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (showDetails) ...[
              const SizedBox(height: AppSpacing.md),
              _buildDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildStateIndicator(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workflow.currentState.name,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (workflow.currentState.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  workflow.currentState.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        _buildStateTypeChip(),
      ],
    );
  }

  Widget _buildStateIndicator() {
    final color = _getStateColor();
    final icon = _getStateIcon();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _buildStateTypeChip() {
    final color = _getStateColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStateType(workflow.currentState.stateType),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Workflow',
          workflow.workflowConfig.name,
          LucideIcons.workflow,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          'Started',
          _formatDateTime(workflow.startedAt),
          LucideIcons.calendar,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildDetailRow(
          'Last Updated',
          _formatDateTime(workflow.updatedAt),
          LucideIcons.clock,
        ),
        if (workflow.availableTransitions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildDetailRow(
            'Available Actions',
            '${workflow.availableTransitions.length} transition${workflow.availableTransitions.length != 1 ? 's' : ''}',
            LucideIcons.arrowRight,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStateColor() {
    switch (workflow.currentState.stateType.toLowerCase()) {
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
    switch (workflow.currentState.stateType.toLowerCase()) {
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

  String _formatStateType(String stateType) {
    return stateType.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class WorkflowProgressWidget extends StatelessWidget {
  final WorkflowInstanceModel workflow;
  final bool showLabels;

  const WorkflowProgressWidget({
    super.key,
    required this.workflow,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final states = workflow.workflowConfig.states
        .where((state) => state.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (states.isEmpty) return const SizedBox.shrink();

    final currentIndex = states.indexWhere(
      (state) => state.id == workflow.currentState.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Text(
            'Workflow Progress',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _buildProgressIndicator(states, currentIndex),
        if (showLabels) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildProgressLabels(states, currentIndex),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator(List<WorkflowStateModel> states, int currentIndex) {
    return Row(
      children: states.asMap().entries.map((entry) {
        final index = entry.key;
        final state = entry.value;
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? AppColors.primary 
                      : isActive 
                          ? AppColors.success 
                          : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent 
                        ? AppColors.primary 
                        : isActive 
                            ? AppColors.success 
                            : AppColors.border,
                    width: 2,
                  ),
                ),
              ),
              if (index < states.length - 1)
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: index < currentIndex ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressLabels(List<WorkflowStateModel> states, int currentIndex) {
    return Row(
      children: states.asMap().entries.map((entry) {
        final index = entry.key;
        final state = entry.value;
        final isActive = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Expanded(
          child: Text(
            state.name,
            style: AppTypography.bodySmall.copyWith(
              color: isCurrent 
                  ? AppColors.primary 
                  : isActive 
                      ? AppColors.textPrimary 
                      : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}