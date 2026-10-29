import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bestie_chat/widgets/dual_clock_widget.dart';
import 'package:bestie_chat/widgets/nudge_banner_card.dart';
import 'package:bestie_chat/services/nudge_service.dart';

void main() {
  testWidgets('DualClockWidget renders names and time zones', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DualClockWidget(
            myName: 'Alex',
            bestieName: 'Sam',
            bestieCity: 'New York',
            bestieUtcOffset: -5,
          ),
        ),
      ),
    );

    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Sam, New York'), findsOneWidget);
  });

  testWidgets('NudgeBannerCard displays reminder copy and action buttons', (tester) async {
    const testStatus = NudgeStatus(
      level: InactivityLevel.triggered,
      isCallInactive: true,
      isChatInactive: false,
      callSummary: '2 days ago you called Sam',
      chatSummary: '3 hours ago you texted Sam',
      primaryAlertTitle: 'Call Reminder 📞',
      primaryAlertMessage: '2 days ago you called Sam! Give them a ring today!',
      hoursSinceLastCall: 49.0,
      hoursSinceLastChat: 3.0,
      streakDays: 4,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NudgeBannerCard(
            status: testStatus,
            bestieName: 'Sam',
            onCallPressed: () {},
            onChatPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Call Sam today'), findsOneWidget);
    expect(find.text("It's been 2 days since your last call."), findsOneWidget);
    expect(find.text('Call now'), findsOneWidget);
    expect(find.text('or open chat'), findsOneWidget);
  });
}
