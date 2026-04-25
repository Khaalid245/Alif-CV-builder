import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppSnackbar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback? onDismiss;

  const AppSnackbar({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
      ),
      child: Row(
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
          if (onDismiss != null)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}