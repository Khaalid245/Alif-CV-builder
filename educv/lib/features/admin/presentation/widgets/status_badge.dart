import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (text, textColor, backgroundColor) = _getStatusColors();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.uppercase.copyWith(
          color: textColor,
        ),
      ),
    );
  }

  (String, Color, Color) _getStatusColors() {
    switch (status.toLowerCase()) {
      case 'active':
        return ('Active', AppColors.success, const Color(0xFFF0FFF4));
      case 'suspended':
        return ('Suspended', AppColors.warning, const Color(0xFFFFF3E0));
      case 'deactivated':
        return ('Deactivated', AppColors.textSecondary, AppColors.surface);
      default:
        return (status, AppColors.textSecondary, AppColors.surface);
    }
  }
}
