import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/time_helper.dart';

class ActiveCallScreen extends StatefulWidget {
  final String bestieName;
  final String bestieAvatar;
  final bool isVideo;
  final Function(int durationSeconds) onCallEnded;

  const ActiveCallScreen({
    super.key,
    required this.bestieName,
    required this.bestieAvatar,
    required this.isVideo,
    required this.onCallEnded,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  late Timer _timer;
  int _seconds = 0;
  bool _isMuted = false;
  late bool _isVideoEnabled;

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.isVideo;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _endCall() {
    _timer.cancel();
    widget.onCallEnded(_seconds);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final timerFormatted = TimeHelper.formatDurationSeconds(_seconds);
    final initialLetter = widget.bestieName.isNotEmpty
        ? widget.bestieName[0].toUpperCase()
        : 'S';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Row matching Mockup (Image 4): Bestie name & Timer on left, PiP on right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bestieName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timerFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // PiP "You" preview box
                  Container(
                    width: 76,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: AppTheme.textMuted,
                          size: 32,
                        ),
                        Positioned(
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Center Avatar & Video Placeholder
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: AppTheme.avatarPurple,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initialLetter,
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "${widget.bestieName}'s video appears here",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom 4 Circular Action Buttons matching Mockup (img55.jpg)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Button
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_off_outlined,
                      backgroundColor: AppTheme.cardDarkSecondary,
                      iconColor: Colors.white,
                      onTap: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),

                    // Camera Button
                    _buildControlButton(
                      icon: Icons.videocam_outlined,
                      backgroundColor: AppTheme.cardDarkSecondary,
                      iconColor: Colors.white,
                      onTap: () {
                        setState(() {
                          _isVideoEnabled = !_isVideoEnabled;
                        });
                      },
                    ),

                    // Flip Camera Button matching img55.jpg
                    _buildControlButton(
                      icon: Icons.flip_camera_ios_outlined,
                      backgroundColor: AppTheme.cardDarkSecondary,
                      iconColor: Colors.white,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Switched camera view'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),

                    // Red End Call Button
                    _buildControlButton(
                      icon: Icons.call_end_rounded,
                      backgroundColor: const Color(0xFFE25C5C),
                      iconColor: Colors.white,
                      onTap: _endCall,
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

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 26,
        ),
      ),
    );
  }
}
