import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/call_record.dart';
import '../core/app_constants.dart';

class StorageService {
  static const String _keyMessages = 'bestie_chat_messages_v2';
  static const String _keyCallLogs = 'bestie_call_logs_v2';
  static const String _keyLastCall = 'bestie_last_call_time_v2';
  static const String _keyLastChat = 'bestie_last_chat_time_v2';
  static const String _keyAppName = 'bestie_app_name';
  static const String _keyMyName = 'bestie_my_name';
  static const String _keyBestieName = 'bestie_friend_name';
  static const String _keyBestieCity = 'bestie_city';
  static const String _keyBestieUtcOffset = 'bestie_utc_offset';
  static const String _keyReminderHours = 'bestie_reminder_threshold_hours';
  static const String _keyStreakCount = 'bestie_streak_count';
  static const String _keyLastStreakDate = 'bestie_last_streak_date';
  static const String _keyHasSeeded = 'bestie_initial_seeded_v2';
  static const String _keyCloudName = 'bestie_cloudinary_cloud_name';
  static const String _keyUploadPreset = 'bestie_cloudinary_upload_preset';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._ensureInitialData();
    return service;
  }

  /// Seeds initial realistic data if first launch:
  /// Includes photos, videos, files, and call records for analytics!
  Future<void> _ensureInitialData() async {
    final hasSeeded = _prefs.getBool(_keyHasSeeded) ?? false;
    if (!hasSeeded) {
      await setStreakCount(0);
      await setAppName(AppConstants.defaultAppName);
      await setMyName(AppConstants.defaultMyName);
      await setBestieName(AppConstants.defaultBestieName);
      await setBestieCity(AppConstants.defaultBestieCity);
      await setBestieUtcOffset(AppConstants.defaultBestieUtcOffset);
      await setReminderThresholdHours(AppConstants.defaultReminderThresholdHours);
      await setCloudinaryCloudName('dlwzojgko');
      await setCloudinaryUploadPreset('besti_chat');
      await saveMessages([]);
      await saveCallLogs([]);
      await _prefs.setBool(_keyHasSeeded, true);
    }
  }

  /// Wipes all chat messages and call logs for a completely clean fresh state
  Future<void> clearAllChatAndLogs() async {
    await saveMessages([]);
    await saveCallLogs([]);
    await _prefs.remove(_keyLastCall);
    await _prefs.remove(_keyLastChat);
    await setStreakCount(0);
  }

  // --- Chat Messages ---
  List<ChatMessage> getMessages() {
    final raw = _prefs.getStringList(_keyMessages) ?? [];
    return raw.map((item) => ChatMessage.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final raw = messages.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_keyMessages, raw);
  }

  // --- Call Logs ---
  List<CallRecord> getCallLogs() {
    final raw = _prefs.getStringList(_keyCallLogs) ?? [];
    return raw.map((item) => CallRecord.fromJson(jsonDecode(item))).toList();
  }

  Future<void> saveCallLogs(List<CallRecord> calls) async {
    final raw = calls.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_keyCallLogs, raw);
  }

  // --- Last Interaction Timestamps ---
  DateTime? getLastCallTime() {
    final str = _prefs.getString(_keyLastCall);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> setLastCallTime(DateTime dt) async {
    await _prefs.setString(_keyLastCall, dt.toIso8601String());
  }

  DateTime? getLastChatTime() {
    final str = _prefs.getString(_keyLastChat);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> setLastChatTime(DateTime dt) async {
    await _prefs.setString(_keyLastChat, dt.toIso8601String());
  }

  // --- Streak Management ---
  int getStreakCount() => _prefs.getInt(_keyStreakCount) ?? 0;
  Future<void> setStreakCount(int count) async => await _prefs.setInt(_keyStreakCount, count);

  String? getLastStreakDate() => _prefs.getString(_keyLastStreakDate);
  Future<void> setLastStreakDate(String dateStr) async => await _prefs.setString(_keyLastStreakDate, dateStr);

  // --- Cloudinary Config ---
  String getCloudinaryCloudName() {
    final val = _prefs.getString(_keyCloudName);
    if (val == null || val.isEmpty || val == 'demo') return 'dlwzojgko';
    return val;
  }
  Future<void> setCloudinaryCloudName(String val) async => await _prefs.setString(_keyCloudName, val);

  String getCloudinaryUploadPreset() {
    final val = _prefs.getString(_keyUploadPreset);
    if (val == null || val.isEmpty || val == 'docs_upload_example_preset') return 'besti_chat';
    return val;
  }
  Future<void> setCloudinaryUploadPreset(String val) async => await _prefs.setString(_keyUploadPreset, val);

  // --- Customizable App Branding & Profiles ---
  String getAppName() => _prefs.getString(_keyAppName) ?? AppConstants.defaultAppName;
  Future<void> setAppName(String name) async => await _prefs.setString(_keyAppName, name);

  String getMyName() => _prefs.getString(_keyMyName) ?? AppConstants.defaultMyName;
  Future<void> setMyName(String name) async => await _prefs.setString(_keyMyName, name);

  String getBestieName() => _prefs.getString(_keyBestieName) ?? AppConstants.defaultBestieName;
  Future<void> setBestieName(String name) async => await _prefs.setString(_keyBestieName, name);

  String getBestieCity() => _prefs.getString(_keyBestieCity) ?? AppConstants.defaultBestieCity;
  Future<void> setBestieCity(String city) async => await _prefs.setString(_keyBestieCity, city);

  int getBestieUtcOffset() => _prefs.getInt(_keyBestieUtcOffset) ?? AppConstants.defaultBestieUtcOffset;
  Future<void> setBestieUtcOffset(int offset) async => await _prefs.setInt(_keyBestieUtcOffset, offset);

  int getReminderThresholdHours() => _prefs.getInt(_keyReminderHours) ?? AppConstants.defaultReminderThresholdHours;
  Future<void> setReminderThresholdHours(int hours) async => await _prefs.setInt(_keyReminderHours, hours);

  Future<void> resetAllData() async {
    await _prefs.remove(_keyHasSeeded);
    await _prefs.remove(_keyMessages);
    await _prefs.remove(_keyCallLogs);
    await _prefs.remove(_keyLastCall);
    await _prefs.remove(_keyLastChat);
    await _prefs.remove(_keyStreakCount);
    await _prefs.remove(_keyLastStreakDate);
    await _ensureInitialData();
  }
}
