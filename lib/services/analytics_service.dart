import '../models/call_record.dart';
import '../models/chat_message.dart';
import '../core/time_helper.dart';

enum AnalyticsRange {
  weekly,
  monthly,
  allTime,
}

class DayActivityPoint {
  final String dayLabel; // "Mon", "Tue", etc.
  final int messageCount;
  final int callMinutes;

  const DayActivityPoint({
    required this.dayLabel,
    required this.messageCount,
    required this.callMinutes,
  });

  int get totalScore => messageCount + (callMinutes * 2);
}

class FriendshipReport {
  final AnalyticsRange range;
  final int totalCallSeconds;
  final int totalCallCount;
  final int videoCallCount;
  final int audioCallCount;
  final int totalMessages;
  final int mediaSharedCount;
  final int pokesExchanged;
  final int longestCallSeconds;
  final int activeDaysCount;
  final int connectionScore; // 0 to 100
  final String scoreLabel;
  final List<DayActivityPoint> dailyActivity;
  final String summaryNarrative;
  final int currentStreak;

  const FriendshipReport({
    required this.range,
    required this.totalCallSeconds,
    required this.totalCallCount,
    required this.videoCallCount,
    required this.audioCallCount,
    required this.totalMessages,
    required this.mediaSharedCount,
    required this.pokesExchanged,
    required this.longestCallSeconds,
    required this.activeDaysCount,
    required this.connectionScore,
    required this.scoreLabel,
    required this.dailyActivity,
    required this.summaryNarrative,
    required this.currentStreak,
  });

  String get totalCallTimeFormatted => TimeHelper.formatDuration(totalCallSeconds);
  int get streakCount => currentStreak;
  String get longestCallFormatted => TimeHelper.formatDuration(longestCallSeconds);
}

class AnalyticsService {
  /// Generate comprehensive friendship analytics report
  static FriendshipReport generateReport({
    required List<CallRecord> calls,
    required List<ChatMessage> messages,
    required int streakCount,
    required String bestieName,
    AnalyticsRange range = AnalyticsRange.weekly,
  }) {
    final now = DateTime.now();
    final int daysFilter = range == AnalyticsRange.weekly
        ? 7
        : range == AnalyticsRange.monthly
            ? 30
            : 3650; // all time

    final cutoff = now.subtract(Duration(days: daysFilter));

    // Filter calls and messages in range
    final filteredCalls = range == AnalyticsRange.allTime
        ? calls
        : calls.where((c) => c.timestamp.isAfter(cutoff)).toList();

    final filteredMessages = range == AnalyticsRange.allTime
        ? messages
        : messages.where((m) => m.timestamp.isAfter(cutoff)).toList();

    // Call metrics
    int totalCallSeconds = 0;
    int videoCalls = 0;
    int audioCalls = 0;
    int longestCall = 0;

    for (final call in filteredCalls) {
      totalCallSeconds += call.durationSeconds;
      if (call.type == CallType.video) {
        videoCalls++;
      } else {
        audioCalls++;
      }
      if (call.durationSeconds > longestCall) {
        longestCall = call.durationSeconds;
      }
    }

    // Message & Media metrics
    int mediaCount = 0;
    int pokeCount = 0;

    for (final msg in filteredMessages) {
      if (msg.type == MessageType.photo ||
          msg.type == MessageType.video ||
          msg.type == MessageType.file) {
        mediaCount++;
      } else if (msg.type == MessageType.poke) {
        pokeCount++;
      }
    }

    // Active days set
    final activeDays = <String>{};
    for (final c in filteredCalls) {
      activeDays.add('${c.timestamp.year}-${c.timestamp.month}-${c.timestamp.day}');
    }
    for (final m in filteredMessages) {
      activeDays.add('${m.timestamp.year}-${m.timestamp.month}-${m.timestamp.day}');
    }

    // Daily breakdown for the last 7 intervals / days
    final dailyActivity = <DayActivityPoint>[];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStr = '${date.year}-${date.month}-${date.day}';
      final dayLabel = dayNames[date.weekday - 1];

      final msgsOnDay = filteredMessages.where((m) {
        return '${m.timestamp.year}-${m.timestamp.month}-${m.timestamp.day}' == dayStr;
      }).length;

      int callSecsOnDay = 0;
      for (final c in filteredCalls) {
        if ('${c.timestamp.year}-${c.timestamp.month}-${c.timestamp.day}' == dayStr) {
          callSecsOnDay += c.durationSeconds;
        }
      }

      dailyActivity.add(DayActivityPoint(
        dayLabel: dayLabel,
        messageCount: msgsOnDay,
        callMinutes: (callSecsOnDay / 60).round(),
      ));
    }

    // Connection Score Algorithm (0 - 100)
    // Weighted by calls (40%), consistency/active days (40%), and messages/media (20%)
    final daysTarget = range == AnalyticsRange.weekly ? 5.0 : 20.0;
    final consistencyScore = (activeDays.length / daysTarget).clamp(0.0, 1.0) * 40;
    final callTargetMins = range == AnalyticsRange.weekly ? 45.0 : 180.0;
    final callScore = ((totalCallSeconds / 60) / callTargetMins).clamp(0.0, 1.0) * 40;
    final msgTarget = range == AnalyticsRange.weekly ? 30.0 : 120.0;
    final msgScore = (filteredMessages.length / msgTarget).clamp(0.0, 1.0) * 20;

    int finalScore = (consistencyScore + callScore + msgScore).round();
    if (finalScore < 40 && (filteredCalls.isNotEmpty || filteredMessages.isNotEmpty)) {
      finalScore = 65; // friendly baseline for active friends
    }
    finalScore = finalScore.clamp(20, 99);

    String scoreLabel = 'Solid Connection 💫';
    if (finalScore >= 85) {
      scoreLabel = 'Inseparable Duo 🔥';
    } else if (finalScore >= 70) {
      scoreLabel = 'Thriving Friendship ✨';
    } else if (finalScore >= 50) {
      scoreLabel = 'Staying in Touch 💛';
    }

    // Dynamic Summary Narrative
    final periodName = range == AnalyticsRange.weekly
        ? 'this week'
        : range == AnalyticsRange.monthly
            ? 'this month'
            : 'overall';

    final totalMins = (totalCallSeconds / 60).round();
    final summaryNarrative =
        'During $periodName, you and $bestieName shared $totalMins minutes across ${filteredCalls.length} calls and sent ${filteredMessages.length} messages. With $mediaCount photos/files and $pokeCount warm pokes, your long-distance bond is strong and thriving!';

    return FriendshipReport(
      range: range,
      totalCallSeconds: totalCallSeconds,
      totalCallCount: filteredCalls.length,
      videoCallCount: videoCalls,
      audioCallCount: audioCalls,
      totalMessages: filteredMessages.length,
      mediaSharedCount: mediaCount,
      pokesExchanged: pokeCount,
      longestCallSeconds: longestCall,
      activeDaysCount: activeDays.length,
      connectionScore: finalScore,
      scoreLabel: scoreLabel,
      dailyActivity: dailyActivity,
      summaryNarrative: summaryNarrative,
      currentStreak: streakCount,
    );
  }
}
