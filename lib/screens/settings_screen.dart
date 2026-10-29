import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';
import '../core/app_constants.dart';
import '../core/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final AppStateProvider provider;

  const SettingsScreen({super.key, required this.provider});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _callRemindersEnabled = true;
  bool _appLockEnabled = false;

  void _showEditProfileDialog() {
    final myNameController = TextEditingController(text: widget.provider.myName);
    final bestieNameController = TextEditingController(text: widget.provider.bestieName);
    final bestieCityController = TextEditingController(text: widget.provider.bestieCity);
    final cloudNameController = TextEditingController(text: widget.provider.cloudinaryCloudName);
    final uploadPresetController = TextEditingController(text: widget.provider.cloudinaryUploadPreset);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Edit Profile & Cloudinary', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('Your Name', myNameController),
              const SizedBox(height: 12),
              _buildDialogField("Bestie's Name", bestieNameController),
              const SizedBox(height: 12),
              _buildDialogField("Bestie's City", bestieCityController),
              const SizedBox(height: 12),
              _buildDialogField('Cloudinary Cloud Name', cloudNameController),
              const SizedBox(height: 12),
              _buildDialogField('Cloudinary Upload Preset', uploadPresetController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              await widget.provider.updateBranding(
                newAppName: widget.provider.appName,
                newMyName: myNameController.text.trim().isEmpty ? AppConstants.defaultMyName : myNameController.text.trim(),
                newBestieName: bestieNameController.text.trim().isEmpty ? AppConstants.defaultBestieName : bestieNameController.text.trim(),
                newBestieCity: bestieCityController.text.trim().isEmpty ? AppConstants.defaultBestieCity : bestieCityController.text.trim(),
                newBestieUtcOffset: widget.provider.bestieUtcOffset,
                newReminderThresholdHours: widget.provider.reminderThresholdHours,
                newCloudName: cloudNameController.text.trim().isEmpty ? 'dlwzojgko' : cloudNameController.text.trim(),
                newUploadPreset: uploadPresetController.text.trim().isEmpty ? 'besti_chat' : uploadPresetController.text.trim(),
              );
              nav.pop();
              if (mounted) {
                setState(() {});
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppTheme.cardDarkSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showCloudinaryDialog() {
    final cloudNameController = TextEditingController(text: widget.provider.cloudinaryCloudName);
    final uploadPresetController = TextEditingController(text: widget.provider.cloudinaryUploadPreset);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Cloudinary Setup', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your Cloudinary credentials for photo, video & file uploads.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildDialogField('Cloud Name', cloudNameController),
              const SizedBox(height: 12),
              _buildDialogField('Upload Preset (Unsigned)', uploadPresetController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              await widget.provider.updateBranding(
                newAppName: widget.provider.appName,
                newMyName: widget.provider.myName,
                newBestieName: widget.provider.bestieName,
                newBestieCity: widget.provider.bestieCity,
                newBestieUtcOffset: widget.provider.bestieUtcOffset,
                newReminderThresholdHours: widget.provider.reminderThresholdHours,
                newCloudName: cloudNameController.text.trim(),
                newUploadPreset: uploadPresetController.text.trim(),
              );
              nav.pop();
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cloudinary credentials saved successfully!'),
                    backgroundColor: Color(0xFF1E293B),
                  ),
                );
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Reset to Clean State', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will clear all mock messages and call logs, starting with a fresh, clean chat.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.provider.clearAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All mock data cleared! Chat is fresh.'),
                    backgroundColor: Color(0xFF1E293B),
                  ),
                );
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showReminderThresholdPicker() {
    final currentDays = (widget.provider.reminderThresholdHours / 24).round();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Remind me after',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...[1, 2, 3, 5, 7].map((days) {
                return ListTile(
                  title: Text(
                    days == 1 ? '1 day' : '$days days',
                    style: TextStyle(
                      color: currentDays == days ? AppTheme.accentBlue : Colors.white,
                      fontWeight: currentDays == days ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: currentDays == days
                      ? const Icon(Icons.check, color: AppTheme.accentBlue)
                      : null,
                  onTap: () async {
                    final nav = Navigator.of(ctx);
                    await widget.provider.updateBranding(
                      newAppName: widget.provider.appName,
                      newMyName: widget.provider.myName,
                      newBestieName: widget.provider.bestieName,
                      newBestieCity: widget.provider.bestieCity,
                      newBestieUtcOffset: widget.provider.bestieUtcOffset,
                      newReminderThresholdHours: days * 24,
                      newCloudName: widget.provider.cloudinaryCloudName,
                      newUploadPreset: widget.provider.cloudinaryUploadPreset,
                    );
                    nav.pop();
                    if (mounted) {
                      setState(() {});
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myName = widget.provider.myName;
    final bestieName = widget.provider.bestieName;
    final initialLetter = myName.isNotEmpty ? myName[0].toUpperCase() : 'A';
    final thresholdDays = (widget.provider.reminderThresholdHours / 24).round();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Title
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 18),

              // User Profile Card matching Mockup (img123.jpg)
              InkWell(
                onTap: _showEditProfileDialog,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.accentBlue,
                        child: Text(
                          initialLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myName,
                              style: const TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Linked with $bestieName',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reminders Section Header
              const Text(
                'Reminders',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Reminders Group Card with exact icons matching img123.jpg
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    // Call Reminders Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Call reminders',
                              style: TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: _callRemindersEnabled,
                            activeThumbColor: AppTheme.accentBlue,
                            onChanged: (val) {
                              setState(() {
                                _callRemindersEnabled = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    // Remind me after
                    _buildSettingsNavRow(
                      icon: Icons.access_time_rounded,
                      title: 'Remind me after',
                      value: '$thresholdDays days',
                      onTap: _showReminderThresholdPicker,
                    ),
                    _buildDivider(),

                    // Quiet hours
                    _buildSettingsNavRow(
                      icon: Icons.nightlight_outlined,
                      title: 'Quiet hours',
                      value: '11 PM to 7 AM',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quiet hours active: 11 PM to 7 AM'),
                            backgroundColor: AppTheme.cardDarkSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Privacy & Storage Section Header
              const Text(
                'Privacy and storage',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Privacy and Storage Group Card with exact icons matching img123.jpg
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    // App Lock Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'App lock',
                              style: TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: _appLockEnabled,
                            activeThumbColor: AppTheme.accentBlue,
                            onChanged: (val) {
                              setState(() {
                                _appLockEnabled = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    // Disappearing messages
                    _buildSettingsNavRow(
                      icon: Icons.hourglass_empty_rounded,
                      title: 'Disappearing messages',
                      value: 'Off',
                      onTap: () {},
                    ),
                    _buildDivider(),

                    // Shared media
                    _buildSettingsNavRow(
                      icon: Icons.image_outlined,
                      title: 'Shared media',
                      value: '212 MB',
                      onTap: () {},
                    ),
                    _buildDivider(),

                    // Cloudinary File Storage
                    _buildSettingsNavRow(
                      icon: Icons.cloud_outlined,
                      title: 'Cloudinary storage',
                      value: widget.provider.cloudinaryCloudName.isNotEmpty
                          ? widget.provider.cloudinaryCloudName
                          : 'Configure',
                      onTap: _showCloudinaryDialog,
                    ),
                    _buildDivider(),

                    // Clear & Reset Data
                    _buildSettingsNavRow(
                      icon: Icons.delete_outline_rounded,
                      title: 'Reset to clean state',
                      value: 'Clear',
                      onTap: _confirmClearAllData,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.6,
      color: AppTheme.dividerColor,
      indent: 52,
      endIndent: 18,
    );
  }

  Widget _buildSettingsNavRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textMuted, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (value.isNotEmpty) ...[
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
            ],
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
