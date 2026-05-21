import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/workflow_models.dart';
import '../providers/workflow_provider.dart';
import '../widgets/workflow_state_widget.dart' as state_widget;
import '../widgets/workflow_transition_widget.dart' as transition_widget;
import '../widgets/workflow_dashboard_widget.dart';
import '../widgets/workflow_progress_widget.dart' as progress_widget;
import '../widgets/workflow_transition_actions_widget.dart' as actions_widget;
import '../widgets/transition_confirmation_dialog.dart' as confirmation_dialog;
import '../widgets/transition_history_widget.dart' as history_widget;

class WorkflowIntegrationWidget extends HookConsumerWidget {
  final String cvId;
  final bool showFullHistory;
  final bool showActions;

  const WorkflowIntegrationWidget({
    super.key,
    required this.cvId,
    this.showFullHistory = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(cvWorkflowProvider(cvId));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref),
            const SizedBox(height: AppSpacing.md),
            _buildContent(context, ref, workflowState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(
          LucideIcons.workflow,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Workflow Status',
          style: AppTypography.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => _refreshWorkflow(ref),
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Refresh Workflow',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
  ) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: AppLoader(),
        ),
      );
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => _refreshWorkflow(ref),
      );
    }

    if (!state.hasWorkflow) {
      return _buildNoWorkflowState(context, ref);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        state_widget.WorkflowStateWidget(
          workflow: state.workflow!,
          showDetails: false,
        ),
        const SizedBox(height: AppSpacing.md),
        progress_widget.WorkflowProgressWidget(
          workflow: state.workflow!,
          showLabels: true,
        ),
        if (showActions && state.availableTransitions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildQuickActions(context, ref, state),
        ],
        if (showFullHistory) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildRecentHistory(context, ref, state),
        ],
      ],
    );
  }

  Widget _buildNoWorkflowState(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.workflow,
            size: 32,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No Active Workflow',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This CV is not currently part of any workflow process.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: () => _showCreateWorkflowDialog(context, ref),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Start Workflow'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
  ) {
    final transitions = state.availableTransitions.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Quick Actions',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (state.availableTransitions.length > 3)
              TextButton(
                onPressed: () => _showAllActionsDialog(context, ref, state),
                child: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: transitions.map((transition) => 
            _buildQuickActionChip(context, ref, transition, state.isTransitioning)
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    WidgetRef ref,
    WorkflowTransitionModel transition,
    bool isLoading,
  ) {
    final color = _getTransitionColor(transition);
    
    return ActionChip(
      onPressed: isLoading 
          ? null 
          : () => _performQuickTransition(context, ref, transition),
      label: Text(transition.name),
      avatar: Icon(
        _getTransitionIcon(transition),
        size: 16,
        color: color,
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      labelStyle: AppTypography.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRecentHistory(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final historyState = ref.watch(transitionHistoryProvider(state.workflow!.id));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showFullHistoryDialog(context, ref, state.workflow!.id),
                  child: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (historyState.isLoading)
              const Center(child: AppLoader())
            else if (historyState.error != null)
              Text(
                'Failed to load history',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              )
            else if (historyState.history.isEmpty)
              Text(
                'No activity yet',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...historyState.history.take(3).map((log) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _buildHistoryItem(log),
                )
              ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryItem(WorkflowTransitionLogModel log) {
    final resultColor = _getResultColor(log.result);
    final resultIcon = _getResultIcon(log.result);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              resultIcon,
              size: 12,
              color: resultColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.fromState.name} → ${log.toState.name}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDateTime(log.performedAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatResult(log.result),
              style: AppTypography.bodySmall.copyWith(
                color: resultColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performQuickTransition(
    BuildContext context,
    WidgetRef ref,
    WorkflowTransitionModel transition,
  ) async {
    if (transition.requiresComment) {
      _showTransitionDialog(context, ref, transition);
      return;
    }

    try {
      await ref.read(cvWorkflowProvider(cvId).notifier).performTransition(
        transition.id,
      );
      
      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Workflow updated successfully!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to update workflow: ${e.toString()}',
        );
      }
    }
  }

  void _showTransitionDialog(
    BuildContext context,
    WidgetRef ref,
    WorkflowTransitionModel transition,
  ) {
    showDialog(
      context: context,
      builder: (context) => confirmation_dialog.TransitionConfirmationDialog(
        title: 'Confirm Transition',
        message: 'Are you sure you want to transition to ${transition.name}?',
        onConfirm: () async {
          Navigator.of(context).pop();
          try {
            await ref.read(cvWorkflowProvider(cvId).notifier).performTransition(
              transition.id,
            );
            
            if (context.mounted) {
              SnackbarHelper.showSuccess(
                context,
                'Workflow updated successfully!',
              );
            }
          } catch (e) {
            if (context.mounted) {
              SnackbarHelper.showError(
                context,
                'Failed to update workflow: ${e.toString()}',
              );
            }
          }
        },
      ),
    );
  }

  void _showAllActionsDialog(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Available Actions'),
        content: SizedBox(
          width: double.maxFinite,
          child: actions_widget.WorkflowTransitionActionsWidget(
            transitions: state.availableTransitions,
            onTransition: (transitionId, comment, metadata) async {
              Navigator.of(context).pop();
              try {
                await ref.read(cvWorkflowProvider(cvId).notifier).performTransition(
                  transitionId,
                  comment: comment,
                  metadata: metadata,
                );
                
                if (context.mounted) {
                  SnackbarHelper.showSuccess(
                    context,
                    'Workflow updated successfully!',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackbarHelper.showError(
                    context,
                    'Failed to update workflow: ${e.toString()}',
                  );
                }
              }
            },
            isLoading: state.isTransitioning,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFullHistoryDialog(BuildContext context, WidgetRef ref, String instanceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workflow History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Consumer(
            builder: (context, ref, child) {
              final historyState = ref.watch(transitionHistoryProvider(instanceId));
              
              return historyState.isLoading
                  ? const Center(child: AppLoader())
                  : historyState.error != null
                      ? AppErrorState(
                          message: historyState.error!,
                          onRetry: () => ref.read(transitionHistoryProvider(instanceId).notifier).loadHistory(refresh: true),
                        )
                      : history_widget.TransitionHistoryWidget(
                          history: historyState.history.map((log) => 
                            history_widget.TransitionHistoryItem(
                              id: log.id,
                              transitionName: '${log.fromState.name} → ${log.toState.name}',
                              status: log.result,
                              userName: log.performedBy ?? 'System',
                              timestamp: log.performedAt,
                              comment: log.comment,
                            )
                          ).toList(),
                          isLoading: historyState.isLoadingMore,
                          hasMore: historyState.hasMore,
                          onLoadMore: () => ref.read(transitionHistoryProvider(instanceId).notifier).loadMoreHistory(),
                        );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkflowDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Workflow'),
        content: const Text(
          'Would you like to start a workflow process for this CV? '
          'This will enable state tracking and transition management.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createWorkflow(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWorkflow(BuildContext context, WidgetRef ref) async {
    try {
      // This would need to be implemented based on your workflow creation logic
      SnackbarHelper.showInfo(
        context,
        'Workflow creation feature coming soon!',
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to create workflow: ${e.toString()}',
        );
      }
    }
  }

  void _refreshWorkflow(WidgetRef ref) {
    ref.read(cvWorkflowProvider(cvId).notifier).refreshWorkflow();
  }

  Color _getTransitionColor(WorkflowTransitionModel transition) {
    switch (transition.toState.stateType.toLowerCase()) {
      case 'final':
        return AppColors.success;
      case 'terminal':
        return AppColors.error;
      case 'intermediate':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTransitionIcon(WorkflowTransitionModel transition) {
    switch (transition.toState.stateType.toLowerCase()) {
      case 'final':
        return LucideIcons.checkCircle;
      case 'terminal':
        return LucideIcons.xCircle;
      case 'intermediate':
        return LucideIcons.arrowRight;
      default:
        return LucideIcons.play;
    }
  }

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'rejected':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getResultIcon(String result) {
    switch (result.toLowerCase()) {
      case 'success':
        return LucideIcons.checkCircle;
      case 'failed':
        return LucideIcons.xCircle;
      case 'rejected':
        return LucideIcons.alertCircle;
      default:
        return LucideIcons.circle;
    }
  }

  String _formatResult(String result) {
    return result[0].toUpperCase() + result.substring(1).toLowerCase();
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