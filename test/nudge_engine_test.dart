import 'package:flutter_test/flutter_test.dart';
import 'package:bestie_chat/core/time_helper.dart';
import 'package:bestie_chat/models/chat_message.dart';
import 'package:bestie_chat/models/call_record.dart';
import 'package:bestie_chat/services/analytics_service.dart';

void main() {
  group('TimeHelper Inactivity & Reminder Engine Tests', () {
    test('formatInactivityPhrase produces exact 2 days ago reminder phrase', () {
      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(hours: 49));

      final phrase = TimeHelper.formatInactivityPhrase(
        lastEventTime: twoDaysAgo,
        actionVerb: 'called',
        bestieName: 'Sam',
      );

      expect(phrase, equals('2 days ago you called Sam'));
    });

    test('formatInactivityPhrase handles yesterday and hours properly', () {
      final now = DateTime.now();
      final oneDayAgo = now.subtract(const Duration(hours: 25));
      final threeHoursAgo = now.subtract(const Duration(hours: 3));

      expect(
        TimeHelper.formatInactivityPhrase(
          lastEventTime: oneDayAgo,
          actionVerb: 'called',
          bestieName: 'Sam',
        ),
        equals('Yesterday you called Sam'),
      );

      expect(
        TimeHelper.formatInactivityPhrase(
          lastEventTime: threeHoursAgo,
          actionVerb: 'texted',
          bestieName: 'Sam',
        ),
        equals('3 hours ago you texted Sam'),
      );
    });

    test('formatDuration formats seconds accurately to MM:SS and HH:MM:SS', () {
      expect(TimeHelper.formatDuration(0), equals('00:00'));
      expect(TimeHelper.formatDuration(65), equals('01:05'));
      expect(TimeHelper.formatDuration(1420), equals('23:40'));
      expect(TimeHelper.formatDuration(3665), equals('1:01:05'));
    });
  });

  group('Cloudinary Media Messages Serialization Tests', () {
    test('Photo, Video, and File messages serialize and deserialize correctly', () {
      final now = DateTime.now();

      final photoMsg = ChatMessage(
        id: 'msg_photo',
        senderId: 'me',
        text: 'Look at this!',
        timestamp: now,
        type: MessageType.photo,
        mediaUrl: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
      );

      final photoJson = photoMsg.toJson();
      final restoredPhoto = ChatMessage.fromJson(photoJson);
      expect(restoredPhoto.type, equals(MessageType.photo));
      expect(restoredPhoto.mediaUrl, contains('cloudinary.com'));

      final fileMsg = ChatMessage(
        id: 'msg_file',
        senderId: 'bestie',
        text: 'Travel Docs',
        timestamp: now,
        type: MessageType.file,
        mediaUrl: 'https://res.cloudinary.com/demo/raw/upload/plan.pdf',
        fileName: 'plan.pdf',
        fileSizeBytes: 1048576,
      );

      final fileJson = fileMsg.toJson();
      final restoredFile = ChatMessage.fromJson(fileJson);
      expect(restoredFile.type, equals(MessageType.file));
      expect(restoredFile.fileName, equals('plan.pdf'));
      expect(restoredFile.fileSizeBytes, equals(1048576));
    });
  });

  group('Analytics & Reporting Tests', () {
    test('generateReport calculates weekly metrics and health score properly', () {
      final now = DateTime.now();
      final calls = [
        CallRecord(
          id: 'c1',
          isOutgoing: true,
          type: CallType.video,
          timestamp: now.subtract(const Duration(days: 1)),
          durationSeconds: 1200,
          status: CallStatus.completed,
        ),
        CallRecord(
          id: 'c2',
          isOutgoing: false,
          type: CallType.audio,
          timestamp: now.subtract(const Duration(days: 3)),
          durationSeconds: 600,
          status: CallStatus.completed,
        ),
      ];

      final messages = [
        ChatMessage(
          id: 'm1',
          senderId: 'me',
          text: 'Hello!',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: 'm2',
          senderId: 'bestie',
          text: 'Hey!',
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
        ChatMessage(
          id: 'm3',
          senderId: 'me',
          text: 'Photo memory',
          timestamp: now.subtract(const Duration(days: 2)),
          type: MessageType.photo,
          mediaUrl: 'https://cloudinary.com/pic.jpg',
        ),
      ];

      final report = AnalyticsService.generateReport(
        calls: calls,
        messages: messages,
        streakCount: 5,
        bestieName: 'Sam',
        range: AnalyticsRange.weekly,
      );

      expect(report.totalCallCount, equals(2));
      expect(report.totalCallSeconds, equals(1800)); // 30 mins
      expect(report.totalMessages, equals(3));
      expect(report.mediaSharedCount, equals(1));
      expect(report.connectionScore, greaterThan(50));
      expect(report.dailyActivity.length, equals(7));
      expect(report.summaryNarrative, contains('Sam'));
    });
  });
}
