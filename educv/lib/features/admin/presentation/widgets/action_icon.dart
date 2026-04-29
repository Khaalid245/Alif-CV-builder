import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class ActionIcon extends StatelessWidget {
  final String action;
  final double size;

  const ActionIcon({
    super.key,
    required this.action,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, backgroundColor) = _getActionStyle();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: iconColor,
      ),
    );
  }

  (IconData, Color, Color) _getActionStyle() {
    switch (action.toLowerCase()) {
      case 'login':
        return (LucideIcons.logIn, AppColors.primary, AppColors.primaryLight);
      case 'register':
        return (LucideIcons.userPlus, AppColors.success, const Color(0xFFF0FFF4));
      case 'pdf_generated':
      case 'cv_generated':
        return (LucideIcons.fileText, const Color(0xFF6A1B9A), const Color(0xFFF3E5F5));
      case 'pdf_downloaded':
      case 'cv_downloaded':
        return (LucideIcons.download, AppColors.primary, AppColors.primaryLight);
      case 'password_changed':
        return (LucideIcons.key, const Color(0xFFE65100), const Color(0xFFFFF3E0));
      case 'account_deleted':
      case 'user_deleted':
        return (LucideIcons.userX, AppColors.error, const Color(0xFFFFEBEE));
      case 'account_suspended':
        return (LucideIcons.userMinus, const Color(0xFFE65100), const Color(0xFFFFF3E0));
      case 'account_activated':
        return (LucideIcons.userCheck, AppColors.success, const Color(0xFFF0FFF4));
      case 'profile_updated':
        return (LucideIcons.edit, AppColors.primary, AppColors.primaryLight);
      default:
        return (LucideIcons.activity, AppColors.textSecondary, AppColors.surface);
    }
  }
}