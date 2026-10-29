import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class FirebaseAuthService {
  FirebaseAuth? get _auth => FirebaseService.isInitialized ? FirebaseAuth.instance : null;

  User? get currentUser => _auth?.currentUser;

  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Quick anonymous sign in for instant 1-on-1 bestie connection
  Future<User?> signInAnonymously() async {
    if (!FirebaseService.isInitialized || _auth == null) {
      debugPrint('ℹ️ Firebase Auth offline - running in local mode');
      return null;
    }
    try {
      final credential = await _auth!.signInAnonymously();
      return credential.user;
    } catch (e) {
      debugPrint('⚠️ Error signing in anonymously: $e');
      return null;
    }
  }

  /// Sign in with Email and Password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isInitialized || _auth == null) return null;
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('⚠️ Error signing in with email: $e');
      rethrow;
    }
  }

  /// Register new user with Email and Password
  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.isInitialized || _auth == null) return null;
    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('⚠️ Error registering user: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth?.signOut();
  }
}
