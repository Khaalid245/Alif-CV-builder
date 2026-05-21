import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/notification_models.dart';

class NotificationStatsCard extends StatelessWidget {
  final NotificationStatsModel stats;

  const NotificationStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Overview',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    stats.totalNotifications.toString(),
                    Icons.notifications,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Unread',
                    stats.unreadNotifications.toString(),
                    Icons.mark_email_unread,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            if (stats.notificationsByType.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'By Type',
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: stats.notificationsByType.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(entry.key).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                      border: Border.all(
                        color: _getTypeColor(entry.key).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_formatType(entry.key)}: ${entry.value}',
                      style: AppTypography.caption.copyWith(
                        color: _getTypeColor(entry.key),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (stats.notificationsByChannel.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'By Channel',
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: stats.notificationsByChannel.entries.map((entry) {
                  return Expanded(
                    child: _buildChannelStat(entry.key, entry.value),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.h6.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textHint,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChannelStat(String channel, int count) {
    final color = _getChannelColor(channel);
    final icon = _getChannelIcon(channel);
    
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          count.toString(),
          style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          _formatChannel(channel),
          style: AppTypography.caption.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
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
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getChannelColor(String channel) {
    switch (channel.toLowerCase()) {
      case 'email':
        return AppColors.primary;
      case 'in_app':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
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

  String _formatType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatChannel(String channel) {
    switch (channel.toLowerCase()) {
      case 'in_app':
        return 'In-App';
      case 'email':
        return 'Email';
      default:
        return channel;
    }
  }
}