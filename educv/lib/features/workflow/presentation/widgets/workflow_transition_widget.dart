import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_input.dart';
import '../../data/models/workflow_models.dart';

class WorkflowTransitionActionsWidget extends StatelessWidget {
  final List<WorkflowTransitionModel> transitions;
  final Function(String transitionId, String? comment, Map<String, dynamic>? metadata)? onTransition;
  final bool isLoading;

  const WorkflowTransitionActionsWidget({
    super.key,
    required this.transitions,
    this.onTransition,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (transitions.isEmpty) {
      return _buildNoActionsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Actions',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...transitions.map((transition) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildTransitionButton(context, transition),
        )),
      ],
    );
  }

  Widget _buildNoActionsState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.lock,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No Actions Available',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'There are no available transitions from the current state.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionButton(BuildContext context, WorkflowTransitionModel transition) {
    final color = _getTransitionColor(transition);
    final icon = _getTransitionIcon(transition);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading 
            ? null 
            : () => _showTransitionDialog(context, transition),
        icon: Icon(icon, size: 18),
        label: Text(transition.name),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showTransitionDialog(BuildContext context, WorkflowTransitionModel transition) {
    showDialog(
      context: context,
      builder: (context) => TransitionConfirmationDialog(
        transition: transition,
        onConfirm: (comment, metadata) {
          Navigator.of(context).pop();
          onTransition?.call(transition.id, comment, metadata);
        },
      ),
    );
  }

  Color _getTransitionColor(WorkflowTransitionModel transition) {
    // Determine color based on transition type or target state
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
    // Determine icon based on transition type or target state
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
}

class TransitionConfirmationDialog extends StatefulWidget {
  final WorkflowTransitionModel transition;
  final Function(String? comment, Map<String, dynamic>? metadata) onConfirm;

  const TransitionConfirmationDialog({
    super.key,
    required this.transition,
    required this.onConfirm,
  });

  @override
  State<TransitionConfirmationDialog> createState() => _TransitionConfirmationDialogState();
}

class _TransitionConfirmationDialogState extends State<TransitionConfirmationDialog> {
  final _commentController = TextEditingController();
  bool _isConfirming = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getTransitionIcon(),
            color: _getTransitionColor(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Confirm Transition',
              style: AppTypography.headingSmall,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTransitionInfo(),
            const SizedBox(height: AppSpacing.lg),
            if (widget.transition.requiresComment) ...[
              _buildCommentField(),
              const SizedBox(height: AppSpacing.md),
            ],
            _buildWarningMessage(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConfirming ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isConfirming ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getTransitionColor(),
            foregroundColor: Colors.white,
          ),
          child: _isConfirming
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.transition.name),
        ),
      ],
    );
  }

  Widget _buildTransitionInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.transition.fromState.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.arrowRight,
                color: AppColors.textSecondary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'To',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.transition.toState.name,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getTransitionColor(),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.transition.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.transition.description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comment *',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Enter a comment for this transition...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.sm),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertTriangle,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This action cannot be undone. The workflow will move to the new state.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    if (widget.transition.requiresComment && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment is required for this transition'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isConfirming = true;
    });

    final comment = _commentController.text.trim().isEmpty 
        ? null 
        : _commentController.text.trim();
    
    widget.onConfirm(comment, null);
  }

  Color _getTransitionColor() {
    switch (widget.transition.toState.stateType.toLowerCase()) {
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

  IconData _getTransitionIcon() {
    switch (widget.transition.toState.stateType.toLowerCase()) {
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
}

class TransitionHistoryWidget extends StatelessWidget {
  final List<WorkflowTransitionLogModel> history;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const TransitionHistoryWidget({
    super.key,
    required this.history,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transition History',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...history.map((log) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildHistoryItem(log),
        )),
        if (hasMore && onLoadMore != null)
          Center(
            child: TextButton(
              onPressed: isLoading ? null : onLoadMore,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load More'),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.history,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No History Available',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No transitions have been performed yet.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(WorkflowTransitionLogModel log) {
    final resultColor = _getResultColor(log.result);
    final resultIcon = _getResultIcon(log.result);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  resultIcon,
                  size: 16,
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
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDateTime(log.performedAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatResult(log.result),
                  style: AppTypography.bodySmall.copyWith(
                    color: resultColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (log.comment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                log.comment,
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
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