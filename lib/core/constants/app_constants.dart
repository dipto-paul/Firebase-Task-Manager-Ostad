
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Task Manager';

  // App colors
  static const Color primaryColor = Color(0xFF635BFF);
  static const Color secondaryColor = Color(0xFF8B80F9);
  static const Color backgroundColor = Color(0xFFF7F8FC);
  static const Color surfaceColor = Colors.white;

  static const Color successColor = Color(0xFF16A34A);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFDC2626);

  static const Color primaryTextColor = Color(0xFF111827);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Layout
  static const double screenPadding = 20.0;
  static const double cardRadius = 18.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius = 14.0;

  // Firestore
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // Notification
  static const String notificationChannelId = 'task_manager_channel';
  static const String notificationChannelName = 'Task Manager Notifications';
  static const String notificationTopic = 'task_updates';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxTaskTitleLength = 100;
}
