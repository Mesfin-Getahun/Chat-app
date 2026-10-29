import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initializes Firebase directly for Flutter with DefaultFirebaseOptions
  static Future<bool> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return true;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('🔥 Firebase initialized successfully with project bestiesync-eb748!');
      return true;
    } catch (e) {
      debugPrint('⚠️ Firebase direct init warning: $e');
      _isInitialized = false;
      return false;
    }
  }
}
