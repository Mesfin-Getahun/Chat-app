import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';
import '../models/call_record.dart';
import '../core/app_theme.dart';
import '../core/time_helper.dart';
import 'active_call_screen.dart';

class CallHistoryScreen extends StatelessWidget {
  final AppStateProvider provider;

  const CallHistoryScreen({super.key, required this.provider});

  void _startCall(BuildContext context, {required bool isVideo}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveCallScreen(
          bestieName: provider.bestieName,
          bestieAvatar: '🦊',
          isVideo: isVideo,
          onCallEnded: (durationSeconds) {
            provider.logCompletedCall(
              isVideo: isVideo,
              durationSeconds: durationSeconds,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calls = provider.callLogs;
    final lastCall = provider.lastCallTime;
    final bestieName = provider.bestieName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History 📞'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call, color: AppTheme.primaryIndigo),
            tooltip: 'Call Bestie',
            onPressed: () => _startCall(context, isVideo: false),
          ),
        ],
      ),
      body: calls.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📞', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No calls yet with $bestieName!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap below to start your first in-app voice or video call!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _startCall(context, isVideo: false),
                    icon: const Icon(Icons.call),
                    label: Text('Call $bestieName'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Top Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.callBlue.withValues(alpha: 0.12),
                        AppTheme.accentViolet.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.callBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.callBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TimeHelper.formatInactivityPhrase(
                                lastEventTime: lastCall,
                                actionVerb: 'called',
                                bestieName: bestieName,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${calls.length} total call${calls.length == 1 ? "" : "s"} logged',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _startCall(context, isVideo: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.callBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Call'),
                      ),
                    ],
                  ),
                ),

                // Call Logs List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: calls.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final call = calls[index];
                      final isVideo = call.type == CallType.video;
                      final durationStr =
                          TimeHelper.formatDuration(call.durationSeconds);
                      final timeAgo =
                          TimeHelper.formatRelativeTime(call.timestamp);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isVideo
                                    ? AppTheme.accentViolet.withValues(alpha: 0.12)
                                    : AppTheme.callBlue.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isVideo
                                    ? Icons.videocam_rounded
                                    : Icons.call_rounded,
                                color: isVideo
                                    ? AppTheme.accentViolet
                                    : AppTheme.callBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isVideo ? 'Video Call' : 'Voice Call',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$timeAgo • Duration: $durationStr',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isVideo
                                    ? Icons.videocam_outlined
                                    : Icons.call_outlined,
                                color: AppTheme.primaryIndigo,
                              ),
                              tooltip: 'Call back',
                              onPressed: () =>
                                  _startCall(context, isVideo: isVideo),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
