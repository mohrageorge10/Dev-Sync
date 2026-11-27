import 'dart:typed_data';

import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Exception thrown when a Cloudinary upload fails or is misconfigured.
class CloudinaryException implements Exception {
  CloudinaryException(this.message);

  final String message;

  @override
  String toString() => message;
}

// Client-side unsigned Cloudinary uploader for CVs and avatars.
class CloudinaryService {
  CloudinaryService({required this._dio});

  final Dio _dio;

  String get _cloudName => (dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '').trim();
  String get _uploadPreset =>
      (dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '').trim();

  // Upload a PDF résumé to the Cloudinary `cvs` folder as raw file so delivery is never blocked.
  Future<String> uploadCv({
    required Uint8List bytes,
    required String fileName,
    String? uid,
  }) => _upload(
    bytes: bytes,
    fileName: fileName,
    folder: FirebaseConstants.cloudinaryCvsFolder,
    resourceType: 'raw',
    publicId: uid == null ? null : '${uid}_${DateTime.now().millisecondsSinceEpoch}',
  );

  // Upload an avatar image to the Cloudinary `avatars` folder and return its secure URL.
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String? uid,
  }) => _upload(
    bytes: bytes,
    fileName: fileName,
    folder: FirebaseConstants.cloudinaryAvatarsFolder,
    resourceType: 'image',
    publicId: uid == null
        ? null
        : '${uid}_avatar_${DateTime.now().millisecondsSinceEpoch}',
  );

  // Upload a completed/shipped project logo image to Cloudinary and return its secure URL.
  Future<String> uploadProjectLogo({
    required Uint8List bytes,
    required String fileName,
    String? projectId,
  }) => _upload(
    bytes: bytes,
    fileName: fileName,
    folder: 'project_logos',
    resourceType: 'image',
    publicId: projectId == null
        ? null
        : '${projectId}_logo_${DateTime.now().millisecondsSinceEpoch}',
  );

  Future<String> _upload({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    required String resourceType,
    String? publicId,
  }) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw CloudinaryException(
        'Missing CLOUDINARY_CLOUD_NAME or CLOUDINARY_UPLOAD_PRESET in .env',
      );
    }

    final url =
        'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload';

    final formData = FormData.fromMap({
      'upload_preset': _uploadPreset,
      'folder': folder,
      'public_id': ?publicId,
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final secureUrl = response.data?['secure_url']?.toString();
      if (secureUrl == null || secureUrl.isEmpty) {
        throw CloudinaryException('Cloudinary did not return a file URL.');
      }
      return secureUrl;
    } on DioException catch (e) {
      final msg =
          e.response?.data?['error']?['message']?.toString() ??
          e.message ??
          'Failed to upload file to Cloudinary.';
      throw CloudinaryException(msg);
    }
  }
}
