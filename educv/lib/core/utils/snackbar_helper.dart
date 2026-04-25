import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      AppColors.success,
      Icons.check_circle_outline,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      AppColors.error,
      Icons.error_outline,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      AppColors.warning,
      Icons.warning_amber_outlined,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      AppColors.primary,
      Icons.info_outline,
    );
  }

  static void _showSnackbar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed ?? () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }
}