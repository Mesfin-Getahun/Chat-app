import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';
import '../core/app_theme.dart';
import '../services/analytics_service.dart';
import '../widgets/dual_clock_widget.dart';
import '../widgets/nudge_banner_card.dart';
import 'active_call_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends StatelessWidget {
  final AppStateProvider provider;
  final Function(int tabIndex) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.provider,
    required this.onNavigateTab,
  });

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '📞 Call with ${provider.bestieName} logged ($durationSeconds s)! Inactivity timer reset!',
                ),
                backgroundColor: AppTheme.accentBlue,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openAnalytics(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyticsScreen(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nudgeStatus = provider.nudgeStatus;
    final weeklyReport = provider.getAnalyticsReport(AnalyticsRange.weekly);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar matching Image 1 & img44.jpg
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.avatarPurpleLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.appName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        ),
                      ),
                      Text(
                        '${provider.myName} and ${provider.bestieName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Streak Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkSecondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${nudgeStatus.streakDays}',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textWhite, size: 22),
                    tooltip: 'Test Nudge Notification',
                    onPressed: () {
                      provider.triggerTestReminder();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔔 Bestie nudge notification sent!'),
                          backgroundColor: AppTheme.accentBlue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Timezone Card
              DualClockWidget(
                myName: provider.myName,
                bestieName: provider.bestieName,
                bestieCity: provider.bestieCity,
                bestieUtcOffset: provider.bestieUtcOffset,
              ),

              const SizedBox(height: 16),

              // Primary Call Bestie Nudge Card (Solid Sky Blue matching img44.jpg)
              NudgeBannerCard(
                status: nudgeStatus,
                bestieName: provider.bestieName,
                onCallPressed: () => _startCall(context, isVideo: false),
                onChatPressed: () => onNavigateTab(1),
              ),

              const SizedBox(height: 16),

              // Weekly Report Card
              InkWell(
                onTap: () => _openAnalytics(context),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF241B36),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.show_chart_rounded,
                          color: AppTheme.textPurple,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly report',
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${weeklyReport.connectionScore}% health',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Recent Actions Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent actions',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onNavigateTab(1),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick Action Chips to spark attention and frequent connection
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionChip(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFF472B6),
                      label: 'Send hug',
                      onTap: () {
                        provider.sendPoke(
                          emoji: '🤗',
                          label: 'Big Hug',
                          text: 'Thinking of you!',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🤗 Big warm hug sent to ${provider.bestieName}!'),
                            backgroundColor: AppTheme.accentBlue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionChip(
                      icon: Icons.mic_rounded,
                      iconColor: AppTheme.accentBlue,
                      label: 'Voice note',
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionChip(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: const Color(0xFFFBBF24),
                      label: 'Question',
                      onTap: () {
                        provider.sendPromptQuestion(
                          'If we could teleport anywhere together this weekend, where are we going? ✈️',
                        );
                        onNavigateTab(1);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Recent Activity Group Card matching img123.jpg styling
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    _buildActivityRow(
                      icon: Icons.phone_outlined,
                      title: 'Voice call with ${provider.bestieName}',
                      subtitle: '24 min • Yesterday',
                      onTap: () => _startCall(context, isVideo: false),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.6,
                      color: AppTheme.dividerColor,
                      indent: 52,
                      endIndent: 18,
                    ),
                    _buildActivityRow(
                      icon: Icons.image_outlined,
                      title: 'Photos & travel plan shared',
                      subtitle: '2 days ago',
                      onTap: () => onNavigateTab(1),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 0.6,
                      color: AppTheme.dividerColor,
                      indent: 52,
                      endIndent: 18,
                    ),
                    _buildActivityRow(
                      icon: Icons.favorite_border_rounded,
                      title: 'Hug sent to ${provider.bestieName}',
                      subtitle: '3 days ago',
                      onTap: () => onNavigateTab(1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentBlue, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
