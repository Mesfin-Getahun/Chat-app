import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../core/time_helper.dart';

class DualClockWidget extends StatelessWidget {
  final String myName;
  final String bestieName;
  final String bestieCity;
  final int bestieUtcOffset;

  const DualClockWidget({
    super.key,
    required this.myName,
    required this.bestieName,
    required this.bestieCity,
    required this.bestieUtcOffset,
  });

  @override
  Widget build(BuildContext context) {
    final nowLocal = DateTime.now();
    final myTimeStr = DateFormat('h:mm a').format(nowLocal);
    final bestieTimeStr = TimeHelper.formatBestieClock(bestieUtcOffset);
    final isBestieSleeping = TimeHelper.isBestieAsleep(bestieUtcOffset);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        myTimeStr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Bestie Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$bestieName, $bestieCity',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        bestieTimeStr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sleeping / Awake pill matching mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.pillPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isBestieSleeping ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 15,
                  color: isBestieSleeping ? const Color(0xFFC4B5FD) : const Color(0xFFFBBF24),
                ),
                const SizedBox(width: 8),
                Text(
                  isBestieSleeping ? '$bestieName is sleeping' : '$bestieName is awake',
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
