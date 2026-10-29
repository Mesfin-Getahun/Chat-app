import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import '../core/app_theme.dart';

class IcebreakerCard extends StatefulWidget {
  final Function(String prompt) onSendPrompt;

  const IcebreakerCard({super.key, required this.onSendPrompt});

  @override
  State<IcebreakerCard> createState() => _IcebreakerCardState();
}

class _IcebreakerCardState extends State<IcebreakerCard> {
  int _currentIndex = 0;

  void _shufflePrompt() {
    setState(() {
      _currentIndex = Random().nextInt(AppConstants.catchUpPrompts.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prompt = AppConstants.catchUpPrompts[_currentIndex];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Text('💡', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Catch-Up Prompt of the Day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                tooltip: 'Shuffle prompt',
                onPressed: _shufflePrompt,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"$prompt"',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => widget.onSendPrompt(prompt),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send to Chat'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryIndigo,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
