import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../models/call_record.dart';
import 'firebase_service.dart';

class FirestoreService {
  FirebaseFirestore? get _db =>
      FirebaseService.isInitialized ? FirebaseFirestore.instance : null;

  /// Stream real-time messages from Cloud Firestore
  Stream<List<ChatMessage>> streamMessages(String chatId) {
    if (!FirebaseService.isInitialized || _db == null) {
      return const Stream.empty();
    }

    return _db!
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ChatMessage.fromJson(data);
      }).toList();
    });
  }

  /// Send message directly to Cloud Firestore
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    if (!FirebaseService.isInitialized || _db == null) return;
    try {
      await _db!
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      debugPrint('⚠️ Error sending message to Firestore: $e');
    }
  }

  /// Log completed call record to Firestore
  Future<void> logCall(String chatId, CallRecord call) async {
    if (!FirebaseService.isInitialized || _db == null) return;
    try {
      await _db!
          .collection('chats')
          .doc(chatId)
          .collection('calls')
          .doc(call.id)
          .set(call.toJson());
    } catch (e) {
      debugPrint('⚠️ Error logging call to Firestore: $e');
    }
  }

  /// Update user presence, sleep status, and time zone
  Future<void> updateUserStatus({
    required String userId,
    required String displayName,
    required String city,
    required int utcOffsetHours,
    required bool isSleeping,
  }) async {
    if (!FirebaseService.isInitialized || _db == null) return;
    try {
      await _db!.collection('users').doc(userId).set({
        'displayName': displayName,
        'city': city,
        'utcOffsetHours': utcOffsetHours,
        'isSleeping': isSleeping,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ Error updating user status in Firestore: $e');
    }
  }

  /// Stream bestie's live status
  Stream<DocumentSnapshot<Map<String, dynamic>>?> streamUserStatus(String userId) {
    if (!FirebaseService.isInitialized || _db == null) {
      return const Stream.empty();
    }
    return _db!.collection('users').doc(userId).snapshots();
  }
}
