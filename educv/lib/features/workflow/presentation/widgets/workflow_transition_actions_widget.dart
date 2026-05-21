import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../data/models/workflow_models.dart';

class WorkflowTransitionActionsWidget extends StatefulWidget {
  final List<WorkflowTransitionModel> transitions;
  final Function(String transitionId, String? comment, Map<String, dynamic>? metadata) onTransition;
  final bool isLoading;

  const WorkflowTransitionActionsWidget({
    super.key,
    required this.transitions,
    required this.onTransition,
    this.isLoading = false,
  });

  @override
  State<WorkflowTransitionActionsWidget> createState() => _WorkflowTransitionActionsWidgetState();
}

class _WorkflowTransitionActionsWidgetState extends State<WorkflowTransitionActionsWidget> {
  WorkflowTransitionModel? selectedTransition;
  final TextEditingController commentController = TextEditingController();
  final Map<String, dynamic> metadata = {};

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transitions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTransitionList(),
        if (selectedTransition != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildTransitionForm(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            LucideIcons.workflow,
            size: 32,
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
            'There are no available transitions for the current state.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Actions',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...widget.transitions.map((transition) => 
          _buildTransitionTile(transition)
        ),
      ],
    );
  }

  Widget _buildTransitionTile(WorkflowTransitionModel transition) {
    final isSelected = selectedTransition?.id == transition.id;
    final color = _getTransitionColor(transition);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? color : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? color.withOpacity(0.05) : null,
      ),
      child: ListTile(
        onTap: widget.isLoading ? null : () => _selectTransition(transition),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getTransitionIcon(transition),
            size: 16,
            color: color,
          ),
        ),
        title: Text(
          transition.name,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? color : null,
          ),
        ),
        subtitle: transition.description.isNotEmpty
            ? Text(
                transition.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transition.requiresComment)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Comment Required',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              isSelected ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitionForm() {
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
              Icon(
                LucideIcons.messageSquare,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                selectedTransition!.requiresComment ? 'Comment (Required)' : 'Comment (Optional)',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a comment about this transition...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.sm),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isLoading ? null : _cancelSelection,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.isLoading || !_canPerformTransition()
                      ? null
                      : _performTransition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTransitionColor(selectedTransition!),
                    foregroundColor: Colors.white,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(selectedTransition!.name),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectTransition(WorkflowTransitionModel transition) {
    setState(() {
      selectedTransition = selectedTransition?.id == transition.id ? null : transition;
      commentController.clear();
      metadata.clear();
    });
  }

  void _cancelSelection() {
    setState(() {
      selectedTransition = null;
      commentController.clear();
      metadata.clear();
    });
  }

  bool _canPerformTransition() {
    if (selectedTransition == null) return false;
    if (selectedTransition!.requiresComment && commentController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _performTransition() {
    if (!_canPerformTransition()) return;

    final comment = commentController.text.trim();
    widget.onTransition(
      selectedTransition!.id,
      comment.isNotEmpty ? comment : null,
      metadata.isNotEmpty ? metadata : null,
    );
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
}