import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/notification_models.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_filter_bar.dart';
import '../widgets/notification_item_card.dart';
import '../widgets/notification_stats_card.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final Set<String> _selectedNotifications = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = context.read<NotificationProvider>();
    provider.loadNotifications();
    provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (_isSelectionMode && _selectedNotifications.isNotEmpty) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () => _markSelectedAsRead(provider),
                      child: Text('Mark Read (${_selectedNotifications.length})'),
                    ),
                    IconButton(
                      onPressed: _exitSelectionMode,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                );
              }
              
              return Row(
                children: [
                  if (provider.unreadCount > 0)
                    TextButton(
                      onPressed: () => _markAllAsRead(provider),
                      child: const Text('Mark All Read'),
                    ),
                  IconButton(
                    onPressed: _enterSelectionMode,
                    icon: const Icon(Icons.checklist),
                    tooltip: 'Select Multiple',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: Column(
              children: [
                NotificationFilterBar(
                  selectedType: provider.selectedType,
                  selectedStatus: provider.selectedStatus,
                  showUnreadOnly: provider.showUnreadOnly,
                  onTypeChanged: provider.setTypeFilter,
                  onStatusChanged: provider.setStatusFilter,
                  onUnreadOnlyChanged: provider.setUnreadOnlyFilter,
                  onClearFilters: provider.clearFilters,
                ),
                Expanded(child: _buildBody(provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    switch (provider.state) {
      case NotificationState.loading:
        return const AppLoader();
      
      case NotificationState.error:
        return AppErrorState(
          message: provider.errorMessage ?? 'Failed to load notifications',
          onRetry: _loadData,
        );
      
      case NotificationState.loaded:
        final notifications = provider.filteredNotifications;
        if (notifications.isEmpty) {
          return const EmptyState(
            title: 'No Notifications',
            message: 'You have no notifications matching the current filters.',
            icon: Icons.notifications_none,
          );
        }
        return _buildNotificationList(provider, notifications);
      
      case NotificationState.initial:
        return const AppLoader();
    }
  }

  Widget _buildNotificationList(NotificationProvider provider, List<NotificationModel> notifications) {
    return Column(
      children: [
        if (provider.stats != null) ...[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: NotificationStatsCard(stats: provider.stats!),
          ),
        ],
        if (_isSelectionMode) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                Text(
                  '${_selectedNotifications.length} notification(s) selected',
                  style: AppTypography.body2,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectAll,
                  child: const Text('Select All'),
                ),
                TextButton(
                  onPressed: _clearSelection,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isSelected = _selectedNotifications.contains(notification.id);
              
              return NotificationItemCard(
                notification: notification,
                isSelected: isSelected,
                isSelectionMode: _isSelectionMode,
                onTap: () => _handleNotificationTap(notification),
                onSelectionChanged: (selected) => _handleSelectionChanged(notification.id, selected),
                onMarkAsRead: () => _markAsRead(provider, notification.id),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (_isSelectionMode) {
      _handleSelectionChanged(notification.id, !_selectedNotifications.contains(notification.id));
    } else {
      _showNotificationDetails(notification);
    }
  }

  void _handleSelectionChanged(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedNotifications.add(id);
      } else {
        _selectedNotifications.remove(id);
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedNotifications.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  void _selectAll() {
    final provider = context.read<NotificationProvider>();
    setState(() {
      _selectedNotifications.addAll(
        provider.filteredNotifications.map((n) => n.id),
      );
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNotifications.clear();
    });
  }

  void _markAsRead(NotificationProvider provider, String id) async {
    final success = await provider.markAsRead(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification marked as read'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _markSelectedAsRead(NotificationProvider provider) async {
    if (_selectedNotifications.isEmpty) return;
    
    final markedCount = await provider.markMultipleAsRead(_selectedNotifications.toList());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked $markedCount notifications as read'),
          backgroundColor: AppColors.success,
        ),
      );
      _exitSelectionMode();
    }
  }

  void _markAllAsRead(NotificationProvider provider) async {
    final unreadIds = provider.notifications
        .where((n) => n.isUnread)
        .map((n) => n.id)
        .toList();
    
    if (unreadIds.isEmpty) return;
    
    final markedCount = await provider.markMultipleAsRead(unreadIds);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked $markedCount notifications as read'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Type: ${_formatNotificationType(notification.notificationType)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Channel: ${_formatChannel(notification.channel)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Created: ${DateFormatter.formatDateTime(notification.createdAt)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (notification.isUnread)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _markAsRead(context.read<NotificationProvider>(), notification.id);
              },
              child: const Text('Mark as Read'),
            ),
        ],
      ),
    );
  }

  String _formatNotificationType(String type) {
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