
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/task_list_screen.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await NotificationService.instance.initialize(
    onTap: _handleLocalNotificationTap,
  );

  await FCMService.instance.initialize(
    onNotificationTap: _handleFCMNotificationTap,
  );

  runApp(const FirebaseTaskManagerApp());
}

void _handleLocalNotificationTap(String? payload) {
  // Task-specific navigation will be connected in the next step.
  // Payload contains JSON data, including taskId when available.
}

void _handleFCMNotificationTap(String? taskId) {
  // Task-specific navigation will be connected in the next step.
}

class FirebaseTaskManagerApp extends StatelessWidget {
  const FirebaseTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
        ),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.inputRadius,
            ),
            borderSide: const BorderSide(
              color: AppConstants.borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.inputRadius,
            ),
            borderSide: const BorderSide(
              color: AppConstants.borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.inputRadius,
            ),
            borderSide: const BorderSide(
              color: AppConstants.primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const TaskListScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
