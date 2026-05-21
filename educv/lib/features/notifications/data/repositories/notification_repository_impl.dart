import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/notification_repository.dart';
import '../models/notification_models.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications({
    String? type,
    String? status,
    bool? unreadOnly,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    
    if (type != null) queryParams['notification_type'] = type;
    if (status != null) queryParams['status'] = status;
    if (unreadOnly == true) queryParams['unread_only'] = 'true';
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await _apiClient.get(
      '/notifications/',
      queryParameters: queryParams,
    );
    
    if (response.success && response.data != null) {
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => NotificationModel.fromJson(json)).toList();
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch notifications');
  }

  @override
  Future<NotificationModel> getNotification(String id) async {
    final response = await _apiClient.get('/notifications/$id/');
    
    if (response.success && response.data != null) {
      return NotificationModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch notification');
  }

  @override
  Future<bool> markAsRead(String id) async {
    final response = await _apiClient.post('/notifications/$id/mark_read/', data: {});
    
    return response.success;
  }

  @override
  Future<int> markMultipleAsRead(List<String> ids) async {
    final response = await _apiClient.post(
      '/notifications/mark_multiple_read/',
      data: {'notification_ids': ids},
    );
    
    if (response.success && response.data != null) {
      return response.data['marked_count'] ?? 0;
    }
    
    throw Exception(response.error?.message ?? 'Failed to mark notifications as read');
  }

  @override
  Future<NotificationStatsModel> getNotificationStats() async {
    final response = await _apiClient.get('/notifications/stats/');
    
    if (response.success && response.data != null) {
      return NotificationStatsModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch notification statistics');
  }

  @override
  Future<NotificationPreferencesModel> getPreferences() async {
    final response = await _apiClient.get('/notifications/preferences/');
    
    if (response.success && response.data != null) {
      return NotificationPreferencesModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch notification preferences');
  }

  @override
  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel preferences) async {
    final response = await _apiClient.put(
      '/notifications/preferences/',
      data: preferences.toJson(),
    );
    
    if (response.success && response.data != null) {
      return NotificationPreferencesModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to update notification preferences');
  }
}