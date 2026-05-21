import 'package:flutter/foundation.dart';
import '../../data/models/notification_models.dart';
import '../../domain/notification_repository.dart';

enum NotificationState { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository);

  NotificationState _state = NotificationState.initial;
  List<NotificationModel> _notifications = [];
  NotificationStatsModel? _stats;
  NotificationPreferencesModel? _preferences;
  String? _errorMessage;
  
  // Filters
  String? _selectedType;
  String? _selectedStatus;
  bool _showUnreadOnly = false;

  NotificationState get state => _state;
  List<NotificationModel> get notifications => _notifications;
  NotificationStatsModel? get stats => _stats;
  NotificationPreferencesModel? get preferences => _preferences;
  String? get errorMessage => _errorMessage;
  String? get selectedType => _selectedType;
  String? get selectedStatus => _selectedStatus;
  bool get showUnreadOnly => _showUnreadOnly;

  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  List<NotificationModel> get filteredNotifications {
    var filtered = _notifications;
    
    if (_selectedType != null) {
      filtered = filtered.where((n) => n.notificationType == _selectedType).toList();
    }
    
    if (_selectedStatus != null) {
      filtered = filtered.where((n) => n.status == _selectedStatus).toList();
    }
    
    if (_showUnreadOnly) {
      filtered = filtered.where((n) => n.isUnread).toList();
    }
    
    return filtered;
  }

  Future<void> loadNotifications() async {
    _setState(NotificationState.loading);
    
    try {
      _notifications = await _repository.getNotifications(
        type: _selectedType,
        status: _selectedStatus,
        unreadOnly: _showUnreadOnly,
      );
      _setState(NotificationState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(NotificationState.error);
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await _repository.getNotificationStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadPreferences() async {
    try {
      _preferences = await _repository.getPreferences();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final success = await _repository.markAsRead(id);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            notificationType: _notifications[index].notificationType,
            channel: _notifications[index].channel,
            priority: _notifications[index].priority,
            status: 'read',
            createdAt: _notifications[index].createdAt,
            sentAt: _notifications[index].sentAt,
            deliveredAt: _notifications[index].deliveredAt,
            readAt: DateTime.now(),
            contextData: _notifications[index].contextData,
            emailSubject: _notifications[index].emailSubject,
            errorMessage: _notifications[index].errorMessage,
            retryCount: _notifications[index].retryCount,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<int> markMultipleAsRead(List<String> ids) async {
    try {
      final markedCount = await _repository.markMultipleAsRead(ids);
      
      // Update local state
      for (final id in ids) {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            notificationType: _notifications[index].notificationType,
            channel: _notifications[index].channel,
            priority: _notifications[index].priority,
            status: 'read',
            createdAt: _notifications[index].createdAt,
            sentAt: _notifications[index].sentAt,
            deliveredAt: _notifications[index].deliveredAt,
            readAt: DateTime.now(),
            contextData: _notifications[index].contextData,
            emailSubject: _notifications[index].emailSubject,
            errorMessage: _notifications[index].errorMessage,
            retryCount: _notifications[index].retryCount,
          );
        }
      }
      
      notifyListeners();
      return markedCount;
    } catch (e) {
      _errorMessage = e.toString();
      return 0;
    }
  }

  Future<bool> updatePreferences(NotificationPreferencesModel preferences) async {
    try {
      _preferences = await _repository.updatePreferences(preferences);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void setTypeFilter(String? type) {
    _selectedType = type;
    notifyListeners();
    loadNotifications();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
    loadNotifications();
  }

  void setUnreadOnlyFilter(bool unreadOnly) {
    _showUnreadOnly = unreadOnly;
    notifyListeners();
    loadNotifications();
  }

  void clearFilters() {
    _selectedType = null;
    _selectedStatus = null;
    _showUnreadOnly = false;
    notifyListeners();
    loadNotifications();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(NotificationState newState) {
    _state = newState;
    notifyListeners();
  }
}