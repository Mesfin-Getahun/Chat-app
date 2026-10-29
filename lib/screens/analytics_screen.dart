import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';
import '../services/analytics_service.dart';
import '../core/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  final AppStateProvider provider;

  const AnalyticsScreen({super.key, required this.provider});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsRange _selectedRange = AnalyticsRange.weekly;

  @override
  Widget build(BuildContext context) {
    final report = widget.provider.getAnalyticsReport(_selectedRange);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 18),

              // 3-Pill Filter (Week, Month, All time) matching Mockup
              Row(
                children: [
                  _buildFilterPill('Week', AnalyticsRange.weekly),
                  const SizedBox(width: 8),
                  _buildFilterPill('Month', AnalyticsRange.monthly),
                  const SizedBox(width: 8),
                  _buildFilterPill('All time', AnalyticsRange.allTime),
                ],
              ),

              const SizedBox(height: 20),

              // Friendship Health Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Friendship health',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Circular Gauge Ring
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: (report.connectionScore / 100.0).clamp(0.0, 1.0),
                                strokeWidth: 7,
                                backgroundColor: AppTheme.cardDarkSecondary,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
                                strokeCap: StrokeCap.round,
                              ),
                              Text(
                                '${report.connectionScore}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: AppTheme.accentGreen,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Up 6% from last week',
                              style: TextStyle(
                                color: AppTheme.accentGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2x2 Metrics Grid matching Mockup (img11.jpg)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _buildMetricTile(
                    icon: Icons.phone_outlined,
                    iconColor: AppTheme.accentBlue,
                    title: 'Calls',
                    value: report.totalCallTimeFormatted,
                  ),
                  _buildMetricTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: AppTheme.accentBlue,
                    title: 'Messages',
                    value: '${report.totalMessages}',
                  ),
                  _buildMetricTile(
                    icon: Icons.image_outlined,
                    iconColor: AppTheme.accentBlue,
                    title: 'Media shared',
                    value: '${report.mediaSharedCount}',
                  ),
                  _buildMetricTile(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: const Color(0xFFF97316),
                    title: 'Streak',
                    value: '${report.streakCount} days',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Talk time by day Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Talk time by day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 7 Bar Chart Columns
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarColumn('M', 0.35, isHighlighted: false),
                        _buildBarColumn('T', 0.20, isHighlighted: false),
                        _buildBarColumn('W', 0.55, isHighlighted: false),
                        _buildBarColumn('T', 0.90, isHighlighted: true),
                        _buildBarColumn('F', 0.40, isHighlighted: false),
                        _buildBarColumn('S', 0.15, isHighlighted: false),
                        _buildBarColumn('S', 0.30, isHighlighted: false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, AnalyticsRange range) {
    final isSelected = _selectedRange == range;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRange = range;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentBlue : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(String day, double fraction, {required bool isHighlighted}) {
    const totalHeight = 100.0;
    final barHeight = (totalHeight * fraction).clamp(12.0, totalHeight);

    return Column(
      children: [
        Container(
          width: 32,
          height: totalHeight,
          decoration: BoxDecoration(
            color: AppTheme.cardDarkSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 32,
            height: barHeight,
            decoration: BoxDecoration(
              color: isHighlighted ? AppTheme.accentBlue : const Color(0xFF243044),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          day,
          style: TextStyle(
            color: isHighlighted ? AppTheme.textWhite : AppTheme.textMuted,
            fontSize: 12,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
