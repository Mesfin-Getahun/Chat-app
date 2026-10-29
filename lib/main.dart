import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/firebase_service.dart';
import 'services/fcm_service.dart';
import 'providers/app_state_provider.dart';
import 'screens/home_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Direct Firebase Connection & Push Messaging
  final firebaseOk = await FirebaseService.initialize();
  if (firebaseOk) {
    await FCMService().initialize();
  }

  // Initialize Local Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize Persistent Storage
  final storageService = await StorageService.init();

  // Initialize Main State Provider
  final appState = AppStateProvider(
    storage: storageService,
    notifications: notificationService,
  );

  runApp(BestieChatApp(appState: appState));
}

class BestieChatApp extends StatelessWidget {
  final AppStateProvider appState;

  const BestieChatApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: appState.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          builder: (context, child) {
            return Container(
              color: const Color(0xFF06090F),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: child!,
              ),
            );
          },
          home: HomeNavigationScreen(provider: appState),
        );
      },
    );
  }
}
