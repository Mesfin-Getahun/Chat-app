import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadResult {
  final bool isSuccess;
  final String secureUrl;
  final String publicId;
  final String format;
  final int bytes;
  final String? errorMessage;

  const CloudinaryUploadResult({
    required this.isSuccess,
    required this.secureUrl,
    required this.publicId,
    required this.format,
    required this.bytes,
    this.errorMessage,
  });
}

class CloudinaryService {
  String cloudName;
  String uploadPreset;

  // Curated aesthetic fallback CDN media for instant preview/demo
  static const List<String> samplePhotos = [
    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=800&q=80', // Friends laughing
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80', // Bestie selfie
    'https://images.unsplash.com/photo-1511632765486-a01980e01a18?auto=format&fit=crop&w=800&q=80', // Celebration
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80', // Sunset beach
  ];

  static List<String> get presetPhotos => samplePhotos;

  static const List<Map<String, String>> presetVideos = [
    {
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      'durationSeconds': '15',
    },
    {
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      'durationSeconds': '22',
    },
  ];

  static const List<Map<String, String>> presetFiles = [
    {
      'fileUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      'fileName': 'trip-plan.pdf',
      'fileSizeBytes': '2450000',
    },
    {
      'fileUrl': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      'fileName': 'playlist_notes.docx',
      'fileSizeBytes': '740000',
    },
  ];

  static const List<Map<String, String>> sampleVideos = [
    {
      'title': 'Bestie Vlog Clip 🎬',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'thumbnail': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      'duration': '15',
    },
    {
      'title': 'Coffee Morning Moment ☕',
      'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'thumbnail': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      'duration': '22',
    },
  ];

  static const List<Map<String, dynamic>> sampleFiles = [
    {
      'name': 'Our_Next_Trip_Plan.pdf',
      'size': 2450000,
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    },
    {
      'name': 'Friendship_Playlist_Notes.docx',
      'size': 740000,
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    },
    {
      'name': 'Shared_Memories_Archive.zip',
      'size': 8500000,
      'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    },
  ];

  CloudinaryService({
    this.cloudName = 'dlwzojgko',
    this.uploadPreset = 'besti_chat',
  });

  /// Upload raw bytes to Cloudinary
  Future<CloudinaryUploadResult> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String resourceType, // 'image', 'video', 'raw'
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CloudinaryUploadResult(
          isSuccess: true,
          secureUrl: data['secure_url'] as String,
          publicId: data['public_id'] as String,
          format: data['format'] as String? ?? 'bin',
          bytes: (data['bytes'] as num?)?.toInt() ?? bytes.length,
        );
      } else {
        debugPrint('Cloudinary upload warning: ${response.body}');
        return CloudinaryUploadResult(
          isSuccess: false,
          secureUrl: '',
          publicId: '',
          format: '',
          bytes: 0,
          errorMessage: 'Cloudinary upload error (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Cloudinary upload exception: $e');
      return CloudinaryUploadResult(
        isSuccess: false,
        secureUrl: '',
        publicId: '',
        format: '',
        bytes: 0,
        errorMessage: e.toString(),
      );
    }
  }

  /// Generate formatted Cloudinary image URL with transformations (e.g. crop, thumbnail)
  String getOptimizedImageUrl(String publicId, {int width = 500, int height = 500}) {
    if (publicId.startsWith('http://') || publicId.startsWith('https://')) {
      return publicId;
    }
    return 'https://res.cloudinary.com/$cloudName/image/upload/c_fill,w_$width,h_$height,q_auto,f_auto/$publicId';
  }
}
