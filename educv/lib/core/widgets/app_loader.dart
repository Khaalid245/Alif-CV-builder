import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppLoader extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.message,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class AppFullScreenLoader extends StatelessWidget {
  final String? message;

  const AppFullScreenLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppLoader(
            message: message ?? 'Loading...',
            size: 32,
          ),
        ),
      ),
    );
  }
}

class AppInlineLoader extends StatelessWidget {
  final String? message;

  const AppInlineLoader({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(width: 12),
            Text(
              message!,
              style: AppTypography.body,
            ),
          ],
        ],
      ),
    );
  }
}