import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/workflow_models.dart';

class RoleBasedWorkflowWidget extends ConsumerWidget {
  final WorkflowInstanceModel workflow;
  final Widget child;
  final List<String> requiredRoles;
  final Widget? fallback;

  const RoleBasedWorkflowWidget({
    super.key,
    required this.workflow,
    required this.child,
    required this.requiredRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (!authState.isAuthenticated) {
      return fallback ?? _buildUnauthorizedWidget();
    }

    final userRole = authState.user?.role ?? 'student';
    final hasPermission = requiredRoles.isEmpty || 
                         requiredRoles.contains(userRole) ||
                         userRole == 'admin'; // Admin has all permissions

    return hasPermission ? child : (fallback ?? _buildUnauthorizedWidget());
  }

  Widget _buildUnauthorizedWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.lock,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Insufficient permissions to perform this action',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkflowPermissionChecker extends ConsumerWidget {
  final WorkflowTransitionModel transition;
  final Widget Function(bool hasPermission) builder;

  const WorkflowPermissionChecker({
    super.key,
    required this.transition,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (!authState.isAuthenticated) {
      return builder(false);
    }

    final userRole = authState.user?.role ?? 'student';
    final hasPermission = transition.allowedRoles.isEmpty || 
                         transition.allowedRoles.contains(userRole) ||
                         userRole == 'admin';

    return builder(hasPermission);
  }
}

class ConditionalWorkflowActions extends ConsumerWidget {
  final List<WorkflowTransitionModel> transitions;
  final Function(String transitionId, String? comment, Map<String, dynamic>? metadata)? onTransition;
  final bool isLoading;

  const ConditionalWorkflowActions({
    super.key,
    required this.transitions,
    this.onTransition,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (!authState.isAuthenticated) {
      return _buildLoginPrompt();
    }

    final userRole = authState.user?.role ?? 'student';
    final allowedTransitions = transitions.where((transition) =>
      transition.allowedRoles.isEmpty || 
      transition.allowedRoles.contains(userRole) ||
      userRole == 'admin'
    ).toList();

    if (allowedTransitions.isEmpty) {
      return _buildNoPermissionsWidget();
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
        ...allowedTransitions.map((transition) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildTransitionButton(context, transition),
        )),
        if (transitions.length > allowedTransitions.length)
          _buildRestrictedActionsInfo(transitions.length - allowedTransitions.length),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.logIn,
            size: 32,
            color: AppColors.info,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Login Required',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Please log in to view and perform workflow actions.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.info,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoPermissionsWidget() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.shield,
            size: 32,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No Available Actions',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You do not have permission to perform any workflow actions at this time.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.warning,
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

  Widget _buildRestrictedActionsInfo(int restrictedCount) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.info,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              '$restrictedCount additional action${restrictedCount != 1 ? 's' : ''} restricted by permissions',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
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

class WorkflowRoleIndicator extends ConsumerWidget {
  final WorkflowTransitionModel transition;

  const WorkflowRoleIndicator({
    super.key,
    required this.transition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transition.allowedRoles.isEmpty) {
      return _buildRoleChip('All Users', AppColors.success);
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: transition.allowedRoles.map((role) => 
        _buildRoleChip(_formatRole(role), _getRoleColor(role))
      ).toList(),
    );
  }

  Widget _buildRoleChip(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  String _formatRole(String role) {
    return role.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.error;
      case 'reviewer':
      case 'supervisor':
        return AppColors.warning;
      case 'student':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Import this in the transition widget file
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
            const SizedBox(height: AppSpacing.md),
            _buildRoleRequirement(),
            const SizedBox(height: AppSpacing.md),
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

  Widget _buildRoleRequirement() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.users,
            size: 14,
            color: AppColors.info,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              widget.transition.allowedRoles.isEmpty
                  ? 'Available to all users'
                  : 'Required roles: ${widget.transition.allowedRoles.join(', ')}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.info,
                fontSize: 11,
              ),
            ),
          ),
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
            contentPadding: const EdgeInsets.all(AppSpacing.md),
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