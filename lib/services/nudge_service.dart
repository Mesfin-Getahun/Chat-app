import '../core/time_helper.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

enum InactivityLevel {
  active,      // Connected recently (< threshold)
  warning,     // Approaching threshold (e.g. > 36 hours)
  triggered,   // >= threshold (e.g. 2 days without call or chat)
}

class NudgeStatus {
  final InactivityLevel level;
  final bool isCallInactive;
  final bool isChatInactive;
  final String callSummary;
  final String chatSummary;
  final String primaryAlertTitle;
  final String primaryAlertMessage;
  final double hoursSinceLastCall;
  final double hoursSinceLastChat;
  final int streakDays;

  const NudgeStatus({
    required this.level,
    required this.isCallInactive,
    required this.isChatInactive,
    required this.callSummary,
    required this.chatSummary,
    required this.primaryAlertTitle,
    required this.primaryAlertMessage,
    required this.hoursSinceLastCall,
    required this.hoursSinceLastChat,
    required this.streakDays,
  });

  int get daysSinceLastCall => (hoursSinceLastCall / 24).round();
}

class NudgeService {
  final StorageService _storage;
  final NotificationService _notifications;

  NudgeService(this._storage, this._notifications);

  /// Evaluates current inactivity status
  NudgeStatus evaluateStatus() {
    final lastCall = _storage.getLastCallTime();
    final lastChat = _storage.getLastChatTime();
    final thresholdHours = _storage.getReminderThresholdHours();
    final bestieName = _storage.getBestieName();
    final streak = _storage.getStreakCount();

    final hoursSinceCall = TimeHelper.getHoursSince(lastCall);
    final hoursSinceChat = TimeHelper.getHoursSince(lastChat);

    final isCallInactive = hoursSinceCall >= thresholdHours;
    final isChatInactive = hoursSinceChat >= thresholdHours;

    final callSummary = TimeHelper.formatInactivityPhrase(
      lastEventTime: lastCall,
      actionVerb: 'called',
      bestieName: bestieName,
    );

    final chatSummary = TimeHelper.formatInactivityPhrase(
      lastEventTime: lastChat,
      actionVerb: 'texted',
      bestieName: bestieName,
    );

    InactivityLevel level = InactivityLevel.active;
    String title = 'Connected with $bestieName 💫';
    String message = 'You and $bestieName are keeping in touch!';

    if (isCallInactive && isChatInactive) {
      level = InactivityLevel.triggered;
      title = 'Miss your bestie? 💛';
      message =
          'It\'s been over ${thresholdHours ~/ 24} days since you last called or chatted with $bestieName! Time to catch up!';
    } else if (isCallInactive) {
      level = InactivityLevel.triggered;
      title = 'Call Reminder 📞';
      message =
          '$callSummary! Give $bestieName a quick voice or video call today!';
    } else if (isChatInactive) {
      level = InactivityLevel.triggered;
      title = 'Chat Reminder 💬';
      message =
          '$chatSummary! Send a quick hello or a poke to brighten their day!';
    } else if (hoursSinceCall >= thresholdHours * 0.75 ||
        hoursSinceChat >= thresholdHours * 0.75) {
      level = InactivityLevel.warning;
      title = 'Catch-up soon ⏳';
      message = 'Almost ${thresholdHours ~/ 24} days since your last call with $bestieName.';
    }

    return NudgeStatus(
      level: level,
      isCallInactive: isCallInactive,
      isChatInactive: isChatInactive,
      callSummary: callSummary,
      chatSummary: chatSummary,
      primaryAlertTitle: title,
      primaryAlertMessage: message,
      hoursSinceLastCall: hoursSinceCall,
      hoursSinceLastChat: hoursSinceChat,
      streakDays: streak,
    );
  }

  /// Called whenever a call completes - resets call timer & updates streak
  Future<void> onCallCompleted() async {
    final now = DateTime.now();
    await _storage.setLastCallTime(now);
    await _updateStreak(now);
  }

  /// Called whenever a chat message is sent/received - resets chat timer & updates streak
  Future<void> onChatMessageSent() async {
    final now = DateTime.now();
    await _storage.setLastChatTime(now);
    await _updateStreak(now);
  }

  /// Triggers an immediate test notification so user can see it
  Future<void> triggerTestReminder() async {
    final status = evaluateStatus();
    await _notifications.showNudgeNotification(
      title: status.primaryAlertTitle,
      body: status.primaryAlertMessage,
    );
  }

  /// Streak Calculation
  Future<void> _updateStreak(DateTime now) async {
    final todayStr = '${now.year}-${now.month}-${now.day}';
    final lastStreakDateStr = _storage.getLastStreakDate();

    if (lastStreakDateStr == todayStr) {
      // Already interacted today, keep current streak
      return;
    }

    if (lastStreakDateStr == null) {
      // First interaction
      await _storage.setStreakCount(1);
      await _storage.setLastStreakDate(todayStr);
      return;
    }

    final parts = lastStreakDateStr.split('-');
    final lastDate = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    final differenceInDays = DateTime(now.year, now.month, now.day)
        .difference(lastDate)
        .inDays;

    if (differenceInDays == 1) {
      // Interacted consecutive day! Streak + 1
      final currentStreak = _storage.getStreakCount();
      await _storage.setStreakCount(currentStreak + 1);
      await _storage.setLastStreakDate(todayStr);
    } else if (differenceInDays > 1) {
      // Missed a day, streak resets to 1
      await _storage.setStreakCount(1);
      await _storage.setLastStreakDate(todayStr);
    }
  }
}
