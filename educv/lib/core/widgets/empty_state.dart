import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                variant: AppButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.actionText,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: title,
      message: message,
      actionText: actionText ?? 'Try Again',
      onAction: onRetry,
    );
  }
}