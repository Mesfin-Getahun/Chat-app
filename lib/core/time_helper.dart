import 'package:intl/intl.dart';

class TimeHelper {
  /// Format a DateTime into relative, friendly human readable string
  /// Examples: "Just now", "5m ago", "2h ago", "Yesterday", "2 days ago", "Oct 24"
  static String formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inSeconds < 45) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  /// Specific reminder phrase for inactivity
  /// e.g. "2 days ago you called your bestie", "3 hours ago", "never called"
  static String formatInactivityPhrase({
    required DateTime? lastEventTime,
    required String actionVerb, // e.g. "called" or "texted"
    required String bestieName,
  }) {
    if (lastEventTime == null) {
      return 'You haven\'t $actionVerb $bestieName yet!';
    }
    final now = DateTime.now();
    final diff = now.difference(lastEventTime);

    if (diff.inDays >= 2) {
      return '${diff.inDays} days ago you $actionVerb $bestieName';
    } else if (diff.inDays == 1) {
      return 'Yesterday you $actionVerb $bestieName';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hours ago you $actionVerb $bestieName';
    } else {
      return 'Earlier today you $actionVerb $bestieName';
    }
  }

  /// Format call duration in seconds to "MM:SS" or "HH:MM:SS"
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = secs.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minStr:$secStr';
    }
    return '$minStr:$secStr';
  }

  static String formatDurationSeconds(int seconds) => formatDuration(seconds);

  /// Calculate bestie's current DateTime given their UTC offset in hours
  static DateTime getBestieTime(int utcOffsetHours) {
    final nowUtc = DateTime.now().toUtc();
    return nowUtc.add(Duration(hours: utcOffsetHours));
  }

  /// Format bestie's current local time
  static String formatBestieClock(int utcOffsetHours) {
    final bestieTime = getBestieTime(utcOffsetHours);
    return DateFormat('h:mm a').format(bestieTime);
  }

  /// Determine if bestie is likely asleep (e.g. between 11 PM and 7 AM local time)
  static bool isBestieAsleep(int utcOffsetHours) {
    final bestieTime = getBestieTime(utcOffsetHours);
    final hour = bestieTime.hour;
    return hour >= 23 || hour < 7;
  }

  /// Returns difference in hours from now
  static double getHoursSince(DateTime? dateTime) {
    if (dateTime == null) return double.infinity;
    final diff = DateTime.now().difference(dateTime);
    return diff.inMinutes / 60.0;
  }
}
