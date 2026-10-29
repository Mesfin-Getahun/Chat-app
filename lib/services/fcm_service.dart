import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initializes Firebase Cloud Messaging for push notifications
  Future<void> initialize() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // Fetch FCM Device Token
      try {
        // ignore: deprecated_member_use
        _fcmToken = await messaging.getToken();
        debugPrint('📲 FCM Token: $_fcmToken');
      } catch (tokenErr) {
        debugPrint('FCM Token notice (e.g. Web vapid key not yet set): $tokenErr');
      }

      // Handle token refreshes
      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('📲 FCM Token refreshed: $newToken');
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 FCM Foreground message received: ${message.notification?.title}');
        final title = message.notification?.title ?? 'Bondly Message';
        final body = message.notification?.body ?? 'You have a new message from your bestie';
        NotificationService().showNudgeNotification(
          title: title,
          body: body,
          payload: message.data.toString(),
        );
      });

      // Handle interaction when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🚀 App opened from notification: ${message.data}');
      });
    } catch (e) {
      debugPrint('FCMService init warning (safely caught): $e');
    }
  }
}
