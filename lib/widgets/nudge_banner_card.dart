import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/nudge_service.dart';

class NudgeBannerCard extends StatelessWidget {
  final NudgeStatus status;
  final String bestieName;
  final VoidCallback onCallPressed;
  final VoidCallback onChatPressed;
  final VoidCallback? onPokePressed;

  const NudgeBannerCard({
    super.key,
    required this.status,
    required this.bestieName,
    required this.onCallPressed,
    required this.onChatPressed,
    this.onPokePressed,
  });

  @override
  Widget build(BuildContext context) {
    final days = status.daysSinceLastCall.clamp(1, 99);
    final daysText = days == 1 ? '1 day' : '$days days';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.accentBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Call $bestieName today',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "It's been $daysText since your last call.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),

          // Full-width white pill button matching img44.jpg
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onCallPressed,
              icon: const Icon(
                Icons.phone_outlined,
                size: 18,
                color: Color(0xFF0284C7),
              ),
              label: const Text(
                'Call now',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Centered "or open chat" link matching img44.jpg
          Center(
            child: GestureDetector(
              onTap: onChatPressed,
              child: const Text(
                'or open chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
