import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/notifications/data/models/notification_models.dart';

void main() {
  group('NotificationModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'title': 'Test Notification',
        'message': 'This is a test message',
        'notification_type': 'cv_updated',
        'channel': 'in_app',
        'priority': 'high',
        'status': 'sent',
        'created_at': '2024-01-01T10:00:00Z',
        'sent_at': '2024-01-01T10:01:00Z',
        'delivered_at': '2024-01-01T10:02:00Z',
        'read_at': null,
        'context_data': {'cv_id': '123'},
        'email_subject': 'CV Updated',
        'error_message': null,
        'retry_count': 0,
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, 'test-id');
      expect(notification.title, 'Test Notification');
      expect(notification.message, 'This is a test message');
      expect(notification.notificationType, 'cv_updated');
      expect(notification.channel, 'in_app');
      expect(notification.priority, 'high');
      expect(notification.status, 'sent');
      expect(notification.contextData, {'cv_id': '123'});
      expect(notification.emailSubject, 'CV Updated');
      expect(notification.retryCount, 0);
      expect(notification.isUnread, true);
      expect(notification.isRead, false);
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 'test-id',
        'title': 'Test',
        'message': 'Message',
        'notification_type': 'cv_created',
        'channel': 'email',
        'priority': 'normal',
        'status': 'pending',
        'created_at': '2024-01-01T10:00:00Z',
        'context_data': {},
        'retry_count': 0,
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.sentAt, null);
      expect(notification.deliveredAt, null);
      expect(notification.readAt, null);
      expect(notification.emailSubject, null);
      expect(notification.errorMessage, null);
      expect(notification.isPending, true);
    });

    test('should correctly identify read status', () {
      final readNotification = NotificationModel.fromJson({
        'id': 'read-id',
        'title': 'Read Notification',
        'message': 'This is read',
        'notification_type': 'cv_updated',
        'channel': 'in_app',
        'priority': 'normal',
        'status': 'read',
        'created_at': '2024-01-01T10:00:00Z',
        'read_at': '2024-01-01T10:05:00Z',
        'context_data': {},
        'retry_count': 0,
      });

      expect(readNotification.isRead, true);
      expect(readNotification.isUnread, false);
    });

    test('should correctly identify failed status', () {
      final failedNotification = NotificationModel.fromJson({
        'id': 'failed-id',
        'title': 'Failed Notification',
        'message': 'This failed',
        'notification_type': 'cv_updated',
        'channel': 'email',
        'priority': 'normal',
        'status': 'failed',
        'created_at': '2024-01-01T10:00:00Z',
        'error_message': 'Email delivery failed',
        'context_data': {},
        'retry_count': 2,
      });

      expect(failedNotification.isFailed, true);
      expect(failedNotification.errorMessage, 'Email delivery failed');
      expect(failedNotification.retryCount, 2);
    });
  });

  group('NotificationStatsModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'total_notifications': 50,
        'unread_notifications': 5,
        'notifications_by_type': {
          'cv_updated': 20,
          'pdf_generated': 15,
          'security_alert': 2,
        },
        'notifications_by_channel': {
          'in_app': 30,
          'email': 20,
        },
        'notifications_by_status': {
          'read': 45,
          'sent': 3,
          'pending': 2,
        },
        'recent_notifications': [
          {
            'id': 'recent-1',
            'title': 'Recent Notification',
            'message': 'Recent message',
            'notification_type': 'cv_updated',
            'channel': 'in_app',
            'priority': 'normal',
            'status': 'sent',
            'created_at': '2024-01-01T10:00:00Z',
            'context_data': {},
            'retry_count': 0,
          }
        ],
      };

      final stats = NotificationStatsModel.fromJson(json);

      expect(stats.totalNotifications, 50);
      expect(stats.unreadNotifications, 5);
      expect(stats.notificationsByType['cv_updated'], 20);
      expect(stats.notificationsByChannel['in_app'], 30);
      expect(stats.notificationsByStatus['read'], 45);
      expect(stats.recentNotifications.length, 1);
      expect(stats.recentNotifications.first.title, 'Recent Notification');
    });
  });

  group('NotificationPreferencesModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 'pref-id',
        'email_notifications_enabled': true,
        'in_app_notifications_enabled': true,
        'cv_updates_email': true,
        'cv_updates_in_app': true,
        'workflow_changes_email': false,
        'workflow_changes_in_app': true,
        'system_notifications_email': true,
        'system_notifications_in_app': true,
        'security_alerts_email': true,
        'security_alerts_in_app': true,
        'digest_frequency': 'daily',
        'quiet_hours_enabled': true,
        'quiet_hours_start': '22:00',
        'quiet_hours_end': '08:00',
      };

      final preferences = NotificationPreferencesModel.fromJson(json);

      expect(preferences.id, 'pref-id');
      expect(preferences.emailNotificationsEnabled, true);
      expect(preferences.inAppNotificationsEnabled, true);
      expect(preferences.cvUpdatesEmail, true);
      expect(preferences.workflowChangesEmail, false);
      expect(preferences.digestFrequency, 'daily');
      expect(preferences.quietHoursEnabled, true);
      expect(preferences.quietHoursStart, '22:00');
      expect(preferences.quietHoursEnd, '08:00');
    });

    test('should convert to JSON correctly', () {
      final preferences = NotificationPreferencesModel(
        id: 'pref-id',
        emailNotificationsEnabled: true,
        inAppNotificationsEnabled: false,
        cvUpdatesEmail: true,
        cvUpdatesInApp: true,
        workflowChangesEmail: false,
        workflowChangesInApp: true,
        systemNotificationsEmail: true,
        systemNotificationsInApp: true,
        securityAlertsEmail: true,
        securityAlertsInApp: true,
        digestFrequency: 'hourly',
        quietHoursEnabled: false,
        quietHoursStart: null,
        quietHoursEnd: null,
      );

      final json = preferences.toJson();

      expect(json['email_notifications_enabled'], true);
      expect(json['in_app_notifications_enabled'], false);
      expect(json['cv_updates_email'], true);
      expect(json['workflow_changes_email'], false);
      expect(json['digest_frequency'], 'hourly');
      expect(json['quiet_hours_enabled'], false);
      expect(json['quiet_hours_start'], null);
    });

    test('should create copy with changes', () {
      final original = NotificationPreferencesModel(
        id: 'pref-id',
        emailNotificationsEnabled: true,
        inAppNotificationsEnabled: true,
        cvUpdatesEmail: true,
        cvUpdatesInApp: true,
        workflowChangesEmail: true,
        workflowChangesInApp: true,
        systemNotificationsEmail: true,
        systemNotificationsInApp: true,
        securityAlertsEmail: true,
        securityAlertsInApp: true,
        digestFrequency: 'immediate',
        quietHoursEnabled: false,
      );

      final updated = original.copyWith(
        emailNotificationsEnabled: false,
        digestFrequency: 'daily',
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
      );

      expect(updated.emailNotificationsEnabled, false);
      expect(updated.digestFrequency, 'daily');
      expect(updated.quietHoursEnabled, true);
      expect(updated.quietHoursStart, '22:00');
      // Unchanged values should remain the same
      expect(updated.inAppNotificationsEnabled, true);
      expect(updated.cvUpdatesEmail, true);
      expect(updated.id, 'pref-id');
    });
  });
}