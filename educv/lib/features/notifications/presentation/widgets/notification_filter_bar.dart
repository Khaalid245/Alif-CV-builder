import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class NotificationFilterBar extends StatelessWidget {
  final String? selectedType;
  final String? selectedStatus;
  final bool showUnreadOnly;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<bool> onUnreadOnlyChanged;
  final VoidCallback onClearFilters;

  const NotificationFilterBar({
    super.key,
    this.selectedType,
    this.selectedStatus,
    required this.showUnreadOnly,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onUnreadOnlyChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedType != null || selectedStatus != null || showUnreadOnly;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filters',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (hasFilters)
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildTypeFilter(),
              _buildStatusFilter(),
              _buildUnreadOnlyFilter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedType,
          hint: const Text('Type'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Types'),
            ),
            ..._notificationTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(type['label']!),
              );
            }).toList(),
          ],
          onChanged: onTypeChanged,
          style: AppTypography.body2,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedStatus,
          hint: const Text('Status'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Status'),
            ),
            ..._notificationStatuses.map((status) {
              return DropdownMenuItem<String>(
                value: status['value'],
                child: Text(status['label']!),
              );
            }).toList(),
          ],
          onChanged: onStatusChanged,
          style: AppTypography.body2,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
        ),
      ),
    );
  }

  Widget _buildUnreadOnlyFilter() {
    return FilterChip(
      label: const Text('Unread Only'),
      selected: showUnreadOnly,
      onSelected: onUnreadOnlyChanged,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.body2.copyWith(
        color: showUnreadOnly ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  static const List<Map<String, String>> _notificationTypes = [
    {'value': 'cv_created', 'label': 'CV Created'},
    {'value': 'cv_updated', 'label': 'CV Updated'},
    {'value': 'cv_completed', 'label': 'CV Completed'},
    {'value': 'pdf_generated', 'label': 'PDF Generated'},
    {'value': 'workflow_changed', 'label': 'Workflow Changed'},
    {'value': 'version_restored', 'label': 'Version Restored'},
    {'value': 'analysis_completed', 'label': 'Analysis Completed'},
    {'value': 'system_maintenance', 'label': 'System Maintenance'},
    {'value': 'account_updated', 'label': 'Account Updated'},
    {'value': 'security_alert', 'label': 'Security Alert'},
  ];

  static const List<Map<String, String>> _notificationStatuses = [
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'sent', 'label': 'Sent'},
    {'value': 'delivered', 'label': 'Delivered'},
    {'value': 'read', 'label': 'Read'},
    {'value': 'failed', 'label': 'Failed'},
  ];
}