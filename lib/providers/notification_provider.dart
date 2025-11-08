import 'package:flutter/foundation.dart';
import '../models/notification_models.dart';
import '../services/notification_service.dart';
import '../services/websocket_service.dart';
import '../utils/logger.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final WebSocketService _wsService = WebSocketService();
  
  List<NotificationResponse> _notifications = [];
  NotificationStatsDto? _stats;
  bool _isLoading = false;
  String? _error;
  
  List<NotificationResponse> get notifications => _notifications;
  NotificationStatsDto? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _stats?.unreadCount ?? 0;

  NotificationProvider() {
    _initialize();
  }

  void _initialize() {
    // Listen to WebSocket notifications
    _wsService.notificationStream.listen((data) {
      _handleWebSocketNotification(data);
    });
    
    // Listen to connection state
    _wsService.connectionStateStream.listen((isConnected) {
      if (isConnected) {
        Logger.debug('WebSocket connected, refreshing notifications');
        refreshNotifications();
      }
    });
  }

  void _handleWebSocketNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    
    switch (type) {
      case 'NOTIFICATION_NEW':
        if (data['data'] != null) {
          final notification = NotificationResponse.fromJson(data['data'] as Map<String, dynamic>);
          _addNewNotification(notification);
        }
        break;
      case 'NOTIFICATION_UNREAD_COUNT':
        if (data['data'] != null) {
          final unreadData = data['data'] as Map<String, dynamic>;
          final unreadCount = unreadData['unreadCount'] as int;
          _updateUnreadCount(unreadCount);
        }
        break;
    }
  }

  void _addNewNotification(NotificationResponse notification) {
    _notifications.insert(0, notification);
    
    // Update stats
    if (_stats != null) {
      _stats = NotificationStatsDto(
        totalCount: _stats!.totalCount + 1,
        unreadCount: _stats!.unreadCount + 1,
        todayCount: _stats!.todayCount + 1,
      );
    }
    
    notifyListeners();
  }

  void _updateUnreadCount(int count) {
    if (_stats != null) {
      _stats = NotificationStatsDto(
        totalCount: _stats!.totalCount,
        unreadCount: count,
        todayCount: _stats!.todayCount,
      );
      notifyListeners();
    }
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final notifications = await _notificationService.getUserNotifications(
        page: 0,
        size: 50,
      );
      
      _notifications = notifications;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      Logger.error('Error loading notifications: $e');
    }
  }

  Future<void> refreshNotifications() async {
    await Future.wait([
      loadNotifications(refresh: true),
      loadStats(),
    ]);
  }

  Future<void> loadStats() async {
    try {
      _stats = await _notificationService.getNotificationStats();
      notifyListeners();
    } catch (e) {
      Logger.error('Error loading notification stats: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final updatedNotification = await _notificationService.markAsRead(notificationId);
      
      // Update locally
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = updatedNotification;
        
        // Update stats
        if (_stats != null && !_notifications[index].isRead && updatedNotification.isRead) {
          _stats = NotificationStatsDto(
            totalCount: _stats!.totalCount,
            unreadCount: _stats!.unreadCount - 1,
            todayCount: _stats!.todayCount,
          );
        }
        
        notifyListeners();
      }
    } catch (e) {
      Logger.error('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update all notifications locally
      _notifications = _notifications.map((n) {
        return NotificationResponse(
          id: n.id,
          recipient: n.recipient,
          actor: n.actor,
          type: n.type,
          targetType: n.targetType,
          targetId: n.targetId,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
          readAt: DateTime.now(),
        );
      }).toList();
      
      // Update stats
      if (_stats != null) {
        _stats = NotificationStatsDto(
          totalCount: _stats!.totalCount,
          unreadCount: 0,
          todayCount: _stats!.todayCount,
        );
      }
      
      notifyListeners();
    } catch (e) {
      Logger.error('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Remove from local list
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      
      // Update stats
      if (_stats != null) {
        _stats = NotificationStatsDto(
          totalCount: _stats!.totalCount - 1,
          unreadCount: notification.isRead ? _stats!.unreadCount : _stats!.unreadCount - 1,
          todayCount: _stats!.todayCount,
        );
      }
      
      notifyListeners();
    } catch (e) {
      Logger.error('Error deleting notification: $e');
    }
  }

  Future<void> deleteOldNotifications() async {
    try {
      await _notificationService.deleteOldNotifications();
      await refreshNotifications();
    } catch (e) {
      Logger.error('Error deleting old notifications: $e');
    }
  }
}
