
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

/// Handles FCM messages while the app is in the background or terminated.
/// This function must remain top-level.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  // Background notifications containing a notification payload are
  // normally displayed automatically by Firebase.
  // Avoid showing a duplicate local notification here.
}

class FCMService {
  FCMService._();

  static final FCMService instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Requests permission and retrieves the device's FCM token.
  Future<String?> initialize({
    Function(String? taskId)? onNotificationTap,
  }) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    _fcmToken = await _messaging.getToken();

    // Listen for refreshed FCM tokens.
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
    });

    // Display a local notification when an FCM message arrives
    // while the app is open.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title']?.toString();
      final body = notification?.body ?? message.data['body']?.toString();

      if (title == null && body == null) return;

      await NotificationService.instance.showNotification(
        title: title ?? 'Task Manager',
        body: body ?? 'You have a new task notification.',
        taskId: message.data['taskId']?.toString(),
        data: message.data,
      );
    });

    // Handle notification taps when the app was in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final taskId = message.data['taskId']?.toString();
      onNotificationTap?.call(taskId);
    });

    // Handle notification taps that launch the terminated app.
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      final taskId = initialMessage.data['taskId']?.toString();

      // Wait until the app's navigation callback is available.
      if (taskId != null) {
        _pendingTaskId = taskId;
      }
    }

    return _fcmToken;
  }

  String? _pendingTaskId;

  String? consumePendingTaskId() {
    final taskId = _pendingTaskId;
    _pendingTaskId = null;
    return taskId;
  }

  /// Use this method to retrieve the current device token again.
  Future<String?> getToken() async {
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  /// Subscribe the device to a topic, e.g. task_updates.
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
