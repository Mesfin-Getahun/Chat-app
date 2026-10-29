import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/cloudinary_service.dart';

class AttachmentSheet extends StatelessWidget {
  final String bestieName;
  final Function({required String imageUrl, String? caption}) onSendPhoto;
  final Function({
    required String videoUrl,
    required String thumbnailUrl,
    required int durationSeconds,
    String? caption,
  }) onSendVideo;
  final Function({
    required String fileUrl,
    required String fileName,
    required int fileSizeBytes,
    String? caption,
  }) onSendFile;

  const AttachmentSheet({
    super.key,
    required this.bestieName,
    required this.onSendPhoto,
    required this.onSendVideo,
    required this.onSendFile,
  });

  static void show(
    BuildContext context, {
    String bestieName = 'Sam',
    required Function({required String imageUrl, String? caption}) onSendPhoto,
    required Function({
      required String videoUrl,
      required String thumbnailUrl,
      required int durationSeconds,
      String? caption,
    }) onSendVideo,
    required Function({
      required String fileUrl,
      required String fileName,
      required int fileSizeBytes,
      String? caption,
    }) onSendFile,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AttachmentSheet(
        bestieName: bestieName,
        onSendPhoto: onSendPhoto,
        onSendVideo: onSendVideo,
        onSendFile: onSendFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title matching img22.jpg
            Text(
              'Share with $bestieName',
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),

            // 2x2 Grid with Blue Outline Icons matching img22.jpg
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.image_outlined,
                  label: 'Photos',
                  onTap: () {
                    Navigator.pop(context);
                    onSendPhoto(
                      imageUrl: CloudinaryService.presetPhotos[0],
                      caption: 'Sunset snapshot 🌅',
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.videocam_outlined,
                  label: 'Videos',
                  onTap: () {
                    Navigator.pop(context);
                    final sample = CloudinaryService.presetVideos[0];
                    onSendVideo(
                      videoUrl: sample['videoUrl']!,
                      thumbnailUrl: sample['thumbnailUrl']!,
                      durationSeconds: int.parse(sample['durationSeconds']!),
                      caption: 'Short memory 🎥',
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Files',
                  onTap: () {
                    Navigator.pop(context);
                    final sample = CloudinaryService.presetFiles[0];
                    onSendFile(
                      fileUrl: sample['fileUrl']!,
                      fileName: sample['fileName']!,
                      fileSizeBytes: int.parse(sample['fileSizeBytes']!),
                      caption: 'Shared document 📄',
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    onSendPhoto(
                      imageUrl: CloudinaryService.presetPhotos[1],
                      caption: 'Photo from camera 📸',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Recent Section matching img22.jpg
            const Text(
              'Recent',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 4 Recent Tiles with Outlined Icons matching img22.jpg
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRecentTile(
                  icon: Icons.image_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    onSendPhoto(imageUrl: CloudinaryService.samplePhotos[0], caption: 'From recent');
                  },
                ),
                _buildRecentTile(
                  icon: Icons.image_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    onSendPhoto(imageUrl: CloudinaryService.samplePhotos[1], caption: 'Beach memory');
                  },
                ),
                _buildRecentTile(
                  icon: Icons.play_arrow_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    final sample = CloudinaryService.presetVideos[0];
                    onSendVideo(
                      videoUrl: sample['videoUrl']!,
                      thumbnailUrl: sample['thumbnailUrl']!,
                      durationSeconds: 15,
                      caption: 'Quick clip',
                    );
                  },
                ),
                _buildRecentTile(
                  icon: Icons.image_outlined,
                  onTap: () {
                    Navigator.pop(context);
                    onSendPhoto(imageUrl: CloudinaryService.samplePhotos[3], caption: 'Sunset view');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTile({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.cardDarkSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            icon,
            color: AppTheme.textMuted,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentBlue, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
