import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_service.dart';

class FirebaseStorageService {
  FirebaseStorage? get _storage =>
      FirebaseService.isInitialized ? FirebaseStorage.instance : null;

  /// Upload file bytes directly to Firebase Storage and get secure public download URL
  Future<String?> uploadMediaBytes({
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    if (!FirebaseService.isInitialized || _storage == null) {
      debugPrint('ℹ️ Firebase Storage offline - using fallback URL');
      return null;
    }

    try {
      final ref = _storage!.ref().child(path);
      final metadata = SettableMetadata(
        contentType: contentType,
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('⚠️ Error uploading media to Firebase Storage: $e');
      return null;
    }
  }
}
