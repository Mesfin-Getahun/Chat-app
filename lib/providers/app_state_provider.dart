import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/call_record.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/nudge_service.dart';
import '../services/cloudinary_service.dart';
import '../services/analytics_service.dart';
import '../services/firebase_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;
  late final NudgeService _nudgeService;
  late final CloudinaryService _cloudinary;
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseStorageService _firebaseStorage = FirebaseStorageService();

  List<ChatMessage> _messages = [];
  List<CallRecord> _callLogs = [];
  late NudgeStatus _nudgeStatus;
  Timer? _periodicStatusTimer;
  StreamSubscription? _firestoreChatSub;

  String get chatId => 'bestie_alex_sam';

  AppStateProvider({
    required StorageService storage,
    required NotificationService notifications,
  })  : _storage = storage,
        _notifications = notifications {
    _nudgeService = NudgeService(_storage, _notifications);
    _cloudinary = CloudinaryService(
      cloudName: _storage.getCloudinaryCloudName(),
      uploadPreset: _storage.getCloudinaryUploadPreset(),
    );
    _loadData();

    // Refresh nudge status every 30 seconds
    _periodicStatusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshNudgeStatus();
    });
  }

  // --- Getters ---
  List<ChatMessage> get messages => _messages;
  List<CallRecord> get callLogs => _callLogs;
  NudgeStatus get nudgeStatus => _nudgeStatus;
  CloudinaryService get cloudinary => _cloudinary;

  String get appName => _storage.getAppName();
  String get myName => _storage.getMyName();
  String get bestieName => _storage.getBestieName();
  String get bestieCity => _storage.getBestieCity();
  int get bestieUtcOffset => _storage.getBestieUtcOffset();
  int get reminderThresholdHours => _storage.getReminderThresholdHours();
  int get streakDays => _storage.getStreakCount();
  DateTime? get lastCallTime => _storage.getLastCallTime();
  DateTime? get lastChatTime => _storage.getLastChatTime();
  String get cloudinaryCloudName => _storage.getCloudinaryCloudName();
  String get cloudinaryUploadPreset => _storage.getCloudinaryUploadPreset();

  void _loadData() {
    _messages = _storage.getMessages();
    _callLogs = _storage.getCallLogs();
    _nudgeStatus = _nudgeService.evaluateStatus();
    _initFirebaseSync();
    notifyListeners();
  }

  void _initFirebaseSync() {
    if (FirebaseService.isInitialized) {
      _auth.signInAnonymously();
      _firestoreChatSub?.cancel();
      _firestoreChatSub = _firestore.streamMessages(chatId).listen((cloudMessages) {
        if (cloudMessages.isNotEmpty) {
          _messages = cloudMessages;
          _storage.saveMessages(_messages);
          notifyListeners();
        }
      });
    }
  }

  FirestoreService get firestore => _firestore;
  FirebaseAuthService get auth => _auth;
  FirebaseStorageService get firebaseStorage => _firebaseStorage;
  bool get isFirebaseConnected => FirebaseService.isInitialized;

  void _refreshNudgeStatus() {
    _nudgeStatus = _nudgeService.evaluateStatus();
    notifyListeners();
  }

  /// Cleans all mock/local data for a completely fresh start
  Future<void> clearAllData() async {
    await _storage.clearAllChatAndLogs();
    _messages = [];
    _callLogs = [];
    _refreshNudgeStatus();
    notifyListeners();
  }

  // --- Analytics & Reports ---
  FriendshipReport getAnalyticsReport(AnalyticsRange range) {
    return AnalyticsService.generateReport(
      calls: _callLogs,
      messages: _messages,
      streakCount: streakDays,
      bestieName: bestieName,
      range: range,
    );
  }

  // Central Helper to Save Locally and Sync to Cloud Firestore in Real-Time
  Future<void> _saveAndSyncMessage(ChatMessage newMsg, {String? simulatedReply}) async {
    _messages.add(newMsg);
    await _storage.saveMessages(_messages);
    await _firestore.sendMessage(chatId, newMsg);
    await _nudgeService.onChatMessageSent();
    _refreshNudgeStatus();

    if (simulatedReply != null) {
      _simulateBestieReply(simulatedReply);
    }
  }

  // --- Chat Actions ---
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: text.trim(),
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Aww thank you! Always brightens my day hearing from you! 😊✨',
    );
  }

  Future<void> sendPhotoMessage({
    required String imageUrl,
    String? caption,
  }) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: caption ?? 'Sent a photo 📸',
      timestamp: DateTime.now(),
      type: MessageType.photo,
      mediaUrl: imageUrl,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'OMG love this photo so much! Saving it right now! 😍📸',
    );
  }

  Future<void> sendGifMessage({
    required String gifUrl,
    String? caption,
  }) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: caption ?? '',
      timestamp: DateTime.now(),
      type: MessageType.gif,
      mediaUrl: gifUrl,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Hahaha this GIF made me laugh so hard!! 😂💖',
    );
  }

  Future<void> sendVideoMessage({
    required String videoUrl,
    required String thumbnailUrl,
    required int durationSeconds,
    String? caption,
  }) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: caption ?? 'Sent a video clip 🎥',
      timestamp: DateTime.now(),
      type: MessageType.video,
      mediaUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Haha this video made me laugh out loud! Good vibes! 😂🎬',
    );
  }

  Future<void> sendFileMessage({
    required String fileUrl,
    required String fileName,
    required int fileSizeBytes,
    String? caption,
  }) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: caption ?? 'Shared a document 📁',
      timestamp: DateTime.now(),
      type: MessageType.file,
      mediaUrl: fileUrl,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Got the file! Opening it now, thank you bestie! 📑✨',
    );
  }

  Future<void> sendVoiceMessage({int durationSeconds = 18}) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: 'Voice note',
      timestamp: DateTime.now(),
      type: MessageType.voice,
      durationSeconds: durationSeconds,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Loved hearing your voice! Talk soon! 🎙️💖',
    );
  }

  Future<void> sendPoke({required String emoji, required String label, required String text}) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: '$emoji $label: $text',
      timestamp: DateTime.now(),
      type: MessageType.poke,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Got your poke! Big warm hug right back at you! 🤗💖',
    );
  }

  Future<void> sendPromptQuestion(String promptQuestion) async {
    final newMsg = ChatMessage(
      id: const Uuid().v4(),
      senderId: 'me',
      text: '💡 Question of the Day: "$promptQuestion"',
      timestamp: DateTime.now(),
      type: MessageType.prompt,
    );

    await _saveAndSyncMessage(
      newMsg,
      simulatedReply: 'Ooh great question! Talking with you right now completely made my day! 🥰',
    );
  }

  Future<void> toggleReaction(String messageId, String emoji) async {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final msg = _messages[index];
    final updatedReactions = List<String>.from(msg.reactions);

    if (updatedReactions.contains(emoji)) {
      updatedReactions.remove(emoji);
    } else {
      updatedReactions.add(emoji);
    }

    _messages[index] = msg.copyWith(reactions: updatedReactions);
    await _storage.saveMessages(_messages);
    notifyListeners();
  }

  void _simulateBestieReply(String replyText) {
    Timer(const Duration(seconds: 2), () async {
      final replyMsg = ChatMessage(
        id: const Uuid().v4(),
        senderId: 'bestie',
        text: replyText,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      _messages.add(replyMsg);
      await _storage.saveMessages(_messages);
      await _nudgeService.onChatMessageSent();
      _refreshNudgeStatus();
    });
  }

  // --- Calling Actions ---
  Future<void> logCompletedCall({
    required bool isVideo,
    required int durationSeconds,
    bool isOutgoing = true,
  }) async {
    final callRecord = CallRecord(
      id: const Uuid().v4(),
      isOutgoing: isOutgoing,
      type: isVideo ? CallType.video : CallType.audio,
      timestamp: DateTime.now(),
      durationSeconds: durationSeconds,
      status: CallStatus.completed,
    );

    _callLogs.insert(0, callRecord);
    await _storage.saveCallLogs(_callLogs);
    await _firestore.logCall(chatId, callRecord);
    await _nudgeService.onCallCompleted();
    _refreshNudgeStatus();
  }

  // --- Settings & Customization ---
  Future<void> updateBranding({
    required String newAppName,
    required String newMyName,
    required String newBestieName,
    required String newBestieCity,
    required int newBestieUtcOffset,
    required int newReminderThresholdHours,
    required String newCloudName,
    required String newUploadPreset,
  }) async {
    await _storage.setAppName(newAppName);
    await _storage.setMyName(newMyName);
    await _storage.setBestieName(newBestieName);
    await _storage.setBestieCity(newBestieCity);
    await _storage.setBestieUtcOffset(newBestieUtcOffset);
    await _storage.setReminderThresholdHours(newReminderThresholdHours);
    await _storage.setCloudinaryCloudName(newCloudName);
    await _storage.setCloudinaryUploadPreset(newUploadPreset);

    _cloudinary.cloudName = newCloudName;
    _cloudinary.uploadPreset = newUploadPreset;

    _refreshNudgeStatus();
  }

  Future<void> triggerTestReminder() async {
    await _nudgeService.triggerTestReminder();
  }

  Future<void> resetToSampleData() async {
    await _storage.resetAllData();
    _loadData();
  }

  @override
  void dispose() {
    _periodicStatusTimer?.cancel();
    _firestoreChatSub?.cancel();
    super.dispose();
  }
}
