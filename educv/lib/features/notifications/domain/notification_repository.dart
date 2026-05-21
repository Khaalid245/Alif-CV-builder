import '../models/notification_models.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications({
    String? type,
    String? status,
    bool? unreadOnly,
    int? limit,
    int? offset,
  });
  
  Future<NotificationModel> getNotification(String id);
  
  Future<bool> markAsRead(String id);
  
  Future<int> markMultipleAsRead(List<String> ids);
  
  Future<NotificationStatsModel> getNotificationStats();
  
  Future<NotificationPreferencesModel> getPreferences();
  
  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel preferences);
}