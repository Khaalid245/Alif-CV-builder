import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
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
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text(
              title,
              style: AppTypography.h2,
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: child,
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
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
                  child: AppButton.secondary(
                    'Cancel',
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton.primary(
                    'Save',
                    onPressed: onSave,
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