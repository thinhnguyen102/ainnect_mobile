import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    Logger.debug('✅ Local notifications initialized');
  }

  Future<bool> requestPermission() async {
    try {
      if (await Permission.notification.isGranted) {
        Logger.debug('✅ Notification permission already granted');
        return true;
      }

      final status = await Permission.notification.request();
      final granted = status.isGranted;
      
      if (granted) {
        Logger.debug('✅ Notification permission granted');
      } else {
        Logger.debug('❌ Notification permission denied');
      }
      
      return granted;
    } catch (e) {
      Logger.error('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'ainnect_channel',
      'Ainnect Notifications',
      channelDescription: 'Thông báo từ Ainnect',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    Logger.debug('📱 Notification shown: $title - $body');
  }

  Future<void> showMessageNotification({
    required int id,
    required String senderName,
    required String message,
    required int conversationId,
  }) async {
    await showNotification(
      id: id,
      title: senderName,
      body: message,
      payload: 'message:$conversationId',
    );
  }

  Future<void> showNotificationAlert({
    required int id,
    required String title,
    required String message,
    int? targetId,
    String? targetType,
  }) async {
    String? payload;
    if (targetId != null && targetType != null) {
      payload = '$targetType:$targetId';
    }

    await showNotification(
      id: id,
      title: title,
      body: message,
      payload: payload,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    Logger.debug('📱 Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      final parts = response.payload!.split(':');
      if (parts.length == 2) {
        final type = parts[0];
        final id = int.tryParse(parts[1]);
        
        if (type == 'message' && id != null) {
          // Navigate to conversation
          Logger.debug('Navigate to conversation: $id');
        } else if (id != null) {
          // Navigate based on target type
          Logger.debug('Navigate to $type: $id');
        }
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

