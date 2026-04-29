import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  (String, Color, Color) _getStatusColors() {
    switch (status.toLowerCase()) {
      case 'active':
        return ('Active', const Color(0xFF2E7D32), const Color(0xFFF0FFF4));
      case 'suspended':
        return ('Suspended', const Color(0xFFE65100), const Color(0xFFFFF3E0));
      case 'deactivated':
        return ('Deactivated', const Color(0xFF616161), const Color(0xFFF5F5F5));
      default:
        return (status, AppColors.textSecondary, AppColors.surface);
    }
  }
}