class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String notificationType;
  final String channel;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final Map<String, dynamic> contextData;
  final String? emailSubject;
  final String? errorMessage;
  final int retryCount;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.channel,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.contextData,
    this.emailSubject,
    this.errorMessage,
    required this.retryCount,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? '',
      channel: json['channel'] ?? '',
      priority: json['priority'] ?? 'normal',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      contextData: json['context_data'] ?? {},
      emailSubject: json['email_subject'],
      errorMessage: json['error_message'],
      retryCount: json['retry_count'] ?? 0,
    );
  }

  bool get isRead => status == 'read';
  bool get isUnread => status != 'read';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}

class NotificationStatsModel {
  final int totalNotifications;
  final int unreadNotifications;
  final Map<String, int> notificationsByType;
  final Map<String, int> notificationsByChannel;
  final Map<String, int> notificationsByStatus;
  final List<NotificationModel> recentNotifications;

  const NotificationStatsModel({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.notificationsByType,
    required this.notificationsByChannel,
    required this.notificationsByStatus,
    required this.recentNotifications,
  });

  factory NotificationStatsModel.fromJson(Map<String, dynamic> json) {
    return NotificationStatsModel(
      totalNotifications: json['total_notifications'] ?? 0,
      unreadNotifications: json['unread_notifications'] ?? 0,
      notificationsByType: Map<String, int>.from(json['notifications_by_type'] ?? {}),
      notificationsByChannel: Map<String, int>.from(json['notifications_by_channel'] ?? {}),
      notificationsByStatus: Map<String, int>.from(json['notifications_by_status'] ?? {}),
      recentNotifications: (json['recent_notifications'] as List<dynamic>?)
          ?.map((n) => NotificationModel.fromJson(n))
          .toList() ?? [],
    );
  }
}

class NotificationPreferencesModel {
  final String id;
  final bool emailNotificationsEnabled;
  final bool inAppNotificationsEnabled;
  final bool cvUpdatesEmail;
  final bool cvUpdatesInApp;
  final bool workflowChangesEmail;
  final bool workflowChangesInApp;
  final bool systemNotificationsEmail;
  final bool systemNotificationsInApp;
  final bool securityAlertsEmail;
  final bool securityAlertsInApp;
  final String digestFrequency;
  final bool quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;

  const NotificationPreferencesModel({
    required this.id,
    required this.emailNotificationsEnabled,
    required this.inAppNotificationsEnabled,
    required this.cvUpdatesEmail,
    required this.cvUpdatesInApp,
    required this.workflowChangesEmail,
    required this.workflowChangesInApp,
    required this.systemNotificationsEmail,
    required this.systemNotificationsInApp,
    required this.securityAlertsEmail,
    required this.securityAlertsInApp,
    required this.digestFrequency,
    required this.quietHoursEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      id: json['id'] ?? '',
      emailNotificationsEnabled: json['email_notifications_enabled'] ?? true,
      inAppNotificationsEnabled: json['in_app_notifications_enabled'] ?? true,
      cvUpdatesEmail: json['cv_updates_email'] ?? true,
      cvUpdatesInApp: json['cv_updates_in_app'] ?? true,
      workflowChangesEmail: json['workflow_changes_email'] ?? true,
      workflowChangesInApp: json['workflow_changes_in_app'] ?? true,
      systemNotificationsEmail: json['system_notifications_email'] ?? true,
      systemNotificationsInApp: json['system_notifications_in_app'] ?? true,
      securityAlertsEmail: json['security_alerts_email'] ?? true,
      securityAlertsInApp: json['security_alerts_in_app'] ?? true,
      digestFrequency: json['digest_frequency'] ?? 'immediate',
      quietHoursEnabled: json['quiet_hours_enabled'] ?? false,
      quietHoursStart: json['quiet_hours_start'],
      quietHoursEnd: json['quiet_hours_end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_notifications_enabled': emailNotificationsEnabled,
      'in_app_notifications_enabled': inAppNotificationsEnabled,
      'cv_updates_email': cvUpdatesEmail,
      'cv_updates_in_app': cvUpdatesInApp,
      'workflow_changes_email': workflowChangesEmail,
      'workflow_changes_in_app': workflowChangesInApp,
      'system_notifications_email': systemNotificationsEmail,
      'system_notifications_in_app': systemNotificationsInApp,
      'security_alerts_email': securityAlertsEmail,
      'security_alerts_in_app': securityAlertsInApp,
      'digest_frequency': digestFrequency,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  NotificationPreferencesModel copyWith({
    bool? emailNotificationsEnabled,
    bool? inAppNotificationsEnabled,
    bool? cvUpdatesEmail,
    bool? cvUpdatesInApp,
    bool? workflowChangesEmail,
    bool? workflowChangesInApp,
    bool? systemNotificationsEmail,
    bool? systemNotificationsInApp,
    bool? securityAlertsEmail,
    bool? securityAlertsInApp,
    String? digestFrequency,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationPreferencesModel(
      id: id,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      inAppNotificationsEnabled: inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
      cvUpdatesEmail: cvUpdatesEmail ?? this.cvUpdatesEmail,
      cvUpdatesInApp: cvUpdatesInApp ?? this.cvUpdatesInApp,
      workflowChangesEmail: workflowChangesEmail ?? this.workflowChangesEmail,
      workflowChangesInApp: workflowChangesInApp ?? this.workflowChangesInApp,
      systemNotificationsEmail: systemNotificationsEmail ?? this.systemNotificationsEmail,
      systemNotificationsInApp: systemNotificationsInApp ?? this.systemNotificationsInApp,
      securityAlertsEmail: securityAlertsEmail ?? this.securityAlertsEmail,
      securityAlertsInApp: securityAlertsInApp ?? this.securityAlertsInApp,
      digestFrequency: digestFrequency ?? this.digestFrequency,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}