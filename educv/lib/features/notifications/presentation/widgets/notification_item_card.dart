import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/notification_models.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onMarkAsRead;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onSelectionChanged,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: notification.isUnread ? AppColors.primaryLight.withOpacity(0.3) : AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelectionMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectionChanged(value ?? false),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.body1.copyWith(
                              fontWeight: notification.isUnread ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.message,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notification.notificationType),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatNotificationType(notification.notificationType),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.priority.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _getChannelIcon(notification.channel),
                          size: 16,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          DateFormatter.formatRelativeTime(notification.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    if (notification.isFailed) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                notification.errorMessage ?? 'Delivery failed',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isSelectionMode && notification.isUnread) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: onMarkAsRead,
                  icon: const Icon(Icons.mark_email_read),
                  iconSize: 20,
                  tooltip: 'Mark as read',
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'cv_created':
      case 'cv_updated':
      case 'cv_completed':
        return AppColors.success;
      case 'pdf_generated':
        return AppColors.primary;
      case 'workflow_changed':
        return AppColors.warning;
      case 'security_alert':
        return AppColors.error;
      case 'system_maintenance':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.textSecondary;
      case 'normal':
        return AppColors.primary;
      case 'high':
        return AppColors.warning;
      case 'urgent':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getChannelIcon(String channel) {
    switch (channel.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'in_app':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  String _formatNotificationType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}