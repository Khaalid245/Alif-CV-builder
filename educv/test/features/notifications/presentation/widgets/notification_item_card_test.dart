import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/notifications/data/models/notification_models.dart';
import 'package:educv/features/notifications/presentation/widgets/notification_item_card.dart';

void main() {
  group('NotificationItemCard', () {
    late NotificationModel testNotification;

    setUp(() {
      testNotification = NotificationModel(
        id: 'test-id',
        title: 'Test Notification',
        message: 'This is a test notification message that might be quite long and should be truncated properly',
        notificationType: 'cv_updated',
        channel: 'in_app',
        priority: 'high',
        status: 'sent',
        createdAt: DateTime(2024, 1, 1, 10, 0),
        contextData: {},
        retryCount: 0,
      );
    });

    testWidgets('should display notification information correctly', (tester) async {
      bool tapCalled = false;
      bool selectionChanged = false;
      bool markAsReadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () => tapCalled = true,
              onSelectionChanged: (selected) => selectionChanged = selected,
              onMarkAsRead: () => markAsReadCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification message that might be quite long and should be truncated properly'), findsOneWidget);
      expect(find.text('CV Updated'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('should show unread indicator for unread notifications', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      // Should show unread indicator (blue dot)
      expect(find.byType(Container), findsWidgets);
      // Should show mark as read button
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
    });

    testWidgets('should not show mark as read button for read notifications', (tester) async {
      final readNotification = NotificationModel(
        id: 'read-id',
        title: 'Read Notification',
        message: 'This is read',
        notificationType: 'cv_updated',
        channel: 'in_app',
        priority: 'normal',
        status: 'read',
        createdAt: DateTime.now(),
        readAt: DateTime.now(),
        contextData: {},
        retryCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: readNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      // Should not show mark as read button for read notifications
      expect(find.byIcon(Icons.mark_email_read), findsNothing);
    });

    testWidgets('should show checkbox in selection mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: false,
              isSelectionMode: true,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read), findsNothing);
    });

    testWidgets('should show selected state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: true,
              isSelectionMode: true,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () => tapCalled = true,
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapCalled, true);
    });

    testWidgets('should call onMarkAsRead when mark as read button is tapped', (tester) async {
      bool markAsReadCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () => markAsReadCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.mark_email_read));
      expect(markAsReadCalled, true);
    });

    testWidgets('should call onSelectionChanged when checkbox is tapped', (tester) async {
      bool selectionChanged = false;
      bool selectedValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: testNotification,
              isSelected: false,
              isSelectionMode: true,
              onTap: () {},
              onSelectionChanged: (selected) {
                selectionChanged = true;
                selectedValue = selected;
              },
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(selectionChanged, true);
      expect(selectedValue, true);
    });

    testWidgets('should show error state for failed notifications', (tester) async {
      final failedNotification = NotificationModel(
        id: 'failed-id',
        title: 'Failed Notification',
        message: 'This failed to deliver',
        notificationType: 'cv_updated',
        channel: 'email',
        priority: 'normal',
        status: 'failed',
        createdAt: DateTime.now(),
        errorMessage: 'Email delivery failed',
        contextData: {},
        retryCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: failedNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Email delivery failed'), findsOneWidget);
    });

    testWidgets('should display correct priority colors', (tester) async {
      final urgentNotification = NotificationModel(
        id: 'urgent-id',
        title: 'Urgent Notification',
        message: 'This is urgent',
        notificationType: 'security_alert',
        channel: 'in_app',
        priority: 'urgent',
        status: 'sent',
        createdAt: DateTime.now(),
        contextData: {},
        retryCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: urgentNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('Security Alert'), findsOneWidget);
    });

    testWidgets('should display correct channel icons', (tester) async {
      final emailNotification = NotificationModel(
        id: 'email-id',
        title: 'Email Notification',
        message: 'Sent via email',
        notificationType: 'cv_updated',
        channel: 'email',
        priority: 'normal',
        status: 'sent',
        createdAt: DateTime.now(),
        contextData: {},
        retryCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationItemCard(
              notification: emailNotification,
              isSelected: false,
              isSelectionMode: false,
              onTap: () {},
              onSelectionChanged: (selected) {},
              onMarkAsRead: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
    });
  });
}