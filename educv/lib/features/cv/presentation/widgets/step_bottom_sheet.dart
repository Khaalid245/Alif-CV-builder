import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class StepBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  const StepBottomSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              title,
              style: AppTypography.h2,
            ),
          ),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: child,
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'Save',
                    onPressed: isLoading ? null : onSave,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}