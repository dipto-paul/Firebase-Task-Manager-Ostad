
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Function(String? payload)? onNotificationTap;

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    'task_manager_channel',
    'Task Manager Notifications',
    description: 'Notifications for your tasks and reminders.',
    importance: Importance.max,
  );

  Future<void> initialize({
    Function(String? payload)? onTap,
  }) async {
    onNotificationTap = onTap;

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? taskId,
    Map<String, dynamic>? data,
  }) async {
    final payloadData = <String, dynamic>{
      if (taskId != null) 'taskId': taskId,
      if (data != null) ...data,
    };

    final String? payload =
    payloadData.isEmpty ? null : jsonEncode(payloadData);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'task_manager_channel',
      'Task Manager Notifications',
      channelDescription: 'Notifications for your tasks and reminders.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
