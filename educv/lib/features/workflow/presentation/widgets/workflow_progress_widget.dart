import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/workflow_models.dart';

class WorkflowProgressWidget extends StatelessWidget {
  final WorkflowInstanceModel workflow;
  final bool showLabels;
  final bool compact;

  const WorkflowProgressWidget({
    super.key,
    required this.workflow,
    this.showLabels = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final states = workflow.workflowConfig.states;
    final currentStateIndex = states.indexWhere(
      (state) => state.id == workflow.currentState.id,
    );

    if (compact) {
      return _buildCompactProgress(states, currentStateIndex);
    }

    return _buildFullProgress(states, currentStateIndex);
  }

  Widget _buildCompactProgress(List<WorkflowStateModel> states, int currentIndex) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.workflow,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Step ${currentIndex + 1} of ${states.length}',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / states.length,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullProgress(List<WorkflowStateModel> states, int currentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Text(
            'Progress',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    'Step ${currentIndex + 1} of ${states.length}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((currentIndex + 1) / states.length * 100).round()}%',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: (currentIndex + 1) / states.length,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              // State indicators
              Row(
                children: states.asMap().entries.map((entry) {
                  final index = entry.key;
                  final state = entry.value;
                  final isCompleted = index < currentIndex;
                  final isCurrent = index == currentIndex;
                  final isUpcoming = index > currentIndex;

                  return Expanded(
                    child: _buildStateIndicator(
                      state,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      isUpcoming: isUpcoming,
                      isFirst: index == 0,
                      isLast: index == states.length - 1,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateIndicator(
    WorkflowStateModel state, {
    required bool isCompleted,
    required bool isCurrent,
    required bool isUpcoming,
    required bool isFirst,
    required bool isLast,
  }) {
    Color indicatorColor;
    IconData indicatorIcon;

    if (isCompleted) {
      indicatorColor = AppColors.success;
      indicatorIcon = LucideIcons.checkCircle;
    } else if (isCurrent) {
      indicatorColor = AppColors.primary;
      indicatorIcon = LucideIcons.circle;
    } else {
      indicatorColor = AppColors.textSecondary.withOpacity(0.3);
      indicatorIcon = LucideIcons.circle;
    }

    return Column(
      children: [
        Row(
          children: [
            if (!isFirst)
              Expanded(
                child: Container(
                  height: 2,
                  color: isCompleted
                      ? AppColors.success
                      : AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: indicatorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: indicatorColor,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Icon(
                indicatorIcon,
                size: 12,
                color: indicatorColor,
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  color: isCompleted
                      ? AppColors.success
                      : AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          state.name,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            color: isCurrent
                ? AppColors.primary
                : isCompleted
                    ? AppColors.success
                    : AppColors.textSecondary,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}