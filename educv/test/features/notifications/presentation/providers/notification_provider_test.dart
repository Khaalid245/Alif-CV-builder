import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:educv/features/notifications/data/models/notification_models.dart';
import 'package:educv/features/notifications/domain/notification_repository.dart';
import 'package:educv/features/notifications/presentation/providers/notification_provider.dart';

import 'notification_provider_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late MockNotificationRepository mockRepository;
  late NotificationProvider provider;

  setUp(() {
    mockRepository = MockNotificationRepository();
    provider = NotificationProvider(mockRepository);
  });

  group('NotificationProvider', () {
    test('initial state should be correct', () {
      expect(provider.state, NotificationState.initial);
      expect(provider.notifications, isEmpty);
      expect(provider.stats, null);
      expect(provider.preferences, null);
      expect(provider.errorMessage, null);
      expect(provider.selectedType, null);
      expect(provider.selectedStatus, null);
      expect(provider.showUnreadOnly, false);
      expect(provider.unreadCount, 0);
    });

    test('loadNotifications should update state correctly on success', () async {
      final mockNotifications = [
        NotificationModel(
          id: '1',
          title: 'Test Notification',
          message: 'Test message',
          notificationType: 'cv_updated',
          channel: 'in_app',
          priority: 'normal',
          status: 'sent',
          createdAt: DateTime.now(),
          contextData: {},
          retryCount: 0,
        ),
        NotificationModel(
          id: '2',
          title: 'Unread Notification',
          message: 'Unread message',
          notificationType: 'pdf_generated',
          channel: 'email',
          priority: 'high',
          status: 'delivered',
          createdAt: DateTime.now(),
          contextData: {},
          retryCount: 0,
        ),
      ];

      when(mockRepository.getNotifications(
        type: null,
        status: null,
        unreadOnly: false,
      )).thenAnswer((_) async => mockNotifications);

      await provider.loadNotifications();

      expect(provider.state, NotificationState.loaded);
      expect(provider.notifications, mockNotifications);
      expect(provider.unreadCount, 2); // Both are unread (not 'read' status)
      expect(provider.errorMessage, null);
    });

    test('loadNotifications should handle errors correctly', () async {
      when(mockRepository.getNotifications(
        type: null,
        status: null,
        unreadOnly: false,
      )).thenThrow(Exception('Network error'));

      await provider.loadNotifications();

      expect(provider.state, NotificationState.error);
      expect(provider.notifications, isEmpty);
      expect(provider.errorMessage, 'Exception: Network error');
    });

    test('loadStats should update stats on success', () async {
      final mockStats = NotificationStatsModel(
        totalNotifications: 10,
        unreadNotifications: 3,
        notificationsByType: {'cv_updated': 5, 'pdf_generated': 3},
        notificationsByChannel: {'in_app': 7, 'email': 3},
        notificationsByStatus: {'read': 7, 'sent': 2, 'pending': 1},
        recentNotifications: [],
      );

      when(mockRepository.getNotificationStats()).thenAnswer((_) async => mockStats);

      await provider.loadStats();

      expect(provider.stats, mockStats);
      expect(provider.errorMessage, null);
    });

    test('markAsRead should update notification status on success', () async {
      final notification = NotificationModel(
        id: '1',
        title: 'Test',
        message: 'Message',
        notificationType: 'cv_updated',
        channel: 'in_app',
        priority: 'normal',
        status: 'sent',
        createdAt: DateTime.now(),
        contextData: {},
        retryCount: 0,
      );

      provider.notifications.add(notification);
      when(mockRepository.markAsRead('1')).thenAnswer((_) async => true);

      final result = await provider.markAsRead('1');

      expect(result, true);
      expect(provider.notifications.first.status, 'read');
      expect(provider.notifications.first.readAt, isNotNull);
    });

    test('markMultipleAsRead should update multiple notifications', () async {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'Test 1',
          message: 'Message 1',
          notificationType: 'cv_updated',
          channel: 'in_app',
          priority: 'normal',
          status: 'sent',
          createdAt: DateTime.now(),
          contextData: {},
          retryCount: 0,
        ),
        NotificationModel(
          id: '2',
          title: 'Test 2',
          message: 'Message 2',
          notificationType: 'pdf_generated',
          channel: 'email',
          priority: 'high',
          status: 'delivered',
          createdAt: DateTime.now(),
          contextData: {},
          retryCount: 0,
        ),
      ];

      provider.notifications.addAll(notifications);
      when(mockRepository.markMultipleAsRead(['1', '2'])).thenAnswer((_) async => 2);

      final result = await provider.markMultipleAsRead(['1', '2']);

      expect(result, 2);
      expect(provider.notifications[0].status, 'read');
      expect(provider.notifications[1].status, 'read');
    });

    test('setTypeFilter should update filter and reload notifications', () async {
      when(mockRepository.getNotifications(
        type: 'cv_updated',
        status: null,
        unreadOnly: false,
      )).thenAnswer((_) async => []);

      provider.setTypeFilter('cv_updated');

      expect(provider.selectedType, 'cv_updated');
      verify(mockRepository.getNotifications(
        type: 'cv_updated',
        status: null,
        unreadOnly: false,
      )).called(1);
    });

    test('setStatusFilter should update filter and reload notifications', () async {
      when(mockRepository.getNotifications(
        type: null,
        status: 'read',
        unreadOnly: false,
      )).thenAnswer((_) async => []);

      provider.setStatusFilter('read');

      expect(provider.selectedStatus, 'read');
      verify(mockRepository.getNotifications(
        type: null,
        status: 'read',
        unreadOnly: false,
      )).called(1);
    });

    test('setUnreadOnlyFilter should update filter and reload notifications', () async {
      when(mockRepository.getNotifications(
        type: null,
        status: null,
        unreadOnly: true,
      )).thenAnswer((_) async => []);

      provider.setUnreadOnlyFilter(true);

      expect(provider.showUnreadOnly, true);
      verify(mockRepository.getNotifications(
        type: null,
        status: null,
        unreadOnly: true,
      )).called(1);
    });

    test('clearFilters should reset all filters and reload notifications', () async {
      // Set some filters first
      provider.setTypeFilter('cv_updated');
      provider.setStatusFilter('read');
      provider.setUnreadOnlyFilter(true);

      when(mockRepository.getNotifications(
        type: null,
        status: null,
        unreadOnly: false,
      )).thenAnswer((_) async => []);

      provider.clearFilters();

      expect(provider.selectedType, null);
      expect(provider.selectedStatus, null);
      expect(provider.showUnreadOnly, false);
    });

    test('filteredNotifications should apply filters correctly', () {
      final notifications = [
        NotificationModel(
          id: '1',
          title: 'CV Updated',
          message: 'Message 1',
          notificationType: 'cv_updated',
          channel: 'in_app',
          priority: 'normal',
          status: 'sent',
          createdAt: DateTime.now(),
          contextData: {},
          retryCount: 0,
        ),
        NotificationModel(
          id: '2',
          title: 'PDF Generated',
          message: 'Message 2',
          notificationType: 'pdf_generated',
          channel: 'email',
          priority: 'high',
          status: 'read',
          createdAt: DateTime.now(),
          contextData: {},
          retryCount: 0,
        ),
      ];

      provider.notifications.addAll(notifications);

      // Test type filter
      provider.setTypeFilter('cv_updated');
      expect(provider.filteredNotifications.length, 1);
      expect(provider.filteredNotifications.first.notificationType, 'cv_updated');

      // Test status filter
      provider.clearFilters();
      provider.setStatusFilter('read');
      expect(provider.filteredNotifications.length, 1);
      expect(provider.filteredNotifications.first.status, 'read');

      // Test unread only filter
      provider.clearFilters();
      provider.setUnreadOnlyFilter(true);
      expect(provider.filteredNotifications.length, 1);
      expect(provider.filteredNotifications.first.isUnread, true);
    });

    test('updatePreferences should update preferences on success', () async {
      final preferences = NotificationPreferencesModel(
        id: 'pref-id',
        emailNotificationsEnabled: false,
        inAppNotificationsEnabled: true,
        cvUpdatesEmail: true,
        cvUpdatesInApp: true,
        workflowChangesEmail: true,
        workflowChangesInApp: true,
        systemNotificationsEmail: true,
        systemNotificationsInApp: true,
        securityAlertsEmail: true,
        securityAlertsInApp: true,
        digestFrequency: 'daily',
        quietHoursEnabled: false,
      );

      when(mockRepository.updatePreferences(preferences)).thenAnswer((_) async => preferences);

      final result = await provider.updatePreferences(preferences);

      expect(result, true);
      expect(provider.preferences, preferences);
    });

    test('clearError should clear error message', () {
      provider.errorMessage = 'Test error';
      provider.clearError();
      expect(provider.errorMessage, null);
    });
  });
}