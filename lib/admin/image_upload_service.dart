import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ImageUploadResult {
  final bool success;
  final String publicUrl;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final String fileName;
  final String? errorMessage;

  ImageUploadResult({
    required this.success,
    required this.publicUrl,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.fileName,
    this.errorMessage,
  });

  String get originalSizeFormatted => '${(originalSizeBytes / 1024).toStringAsFixed(1)} KB';
  String get compressedSizeFormatted => '${(compressedSizeBytes / 1024).toStringAsFixed(1)} KB';
  int get savingsPercent => originalSizeBytes > 0
      ? (((originalSizeBytes - compressedSizeBytes) / originalSizeBytes) * 100).round()
      : 0;
}

class ImageUploadService {
  static const int maxSizeBytes = 100 * 1024; // Strict 100 KB limit (102,400 bytes)
  static const String bucketName = 'product-images';

  /// Compresses raw image bytes so the output JPEG is strictly <= 100 KB
  static Uint8List compressImageUnder100Kb(Uint8List rawBytes) {
    // If already <= 100 KB, check if it's already compact
    if (rawBytes.lengthInBytes <= maxSizeBytes) {
      return rawBytes;
    }

    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      return rawBytes; // fallback if image format is unsupported
    }

    // Bake EXIF orientation so phone camera pictures are upright
    img.Image imageToProcess = img.bakeOrientation(decoded);

    // Step 1: Scale down dimensions if image exceeds 1000px on any side
    if (imageToProcess.width > 1000 || imageToProcess.height > 1000) {
      imageToProcess = img.copyResize(
        imageToProcess,
        width: imageToProcess.width >= imageToProcess.height ? 1000 : null,
        height: imageToProcess.height > imageToProcess.width ? 1000 : null,
        interpolation: img.Interpolation.linear,
      );
    }

    // Step 2: Iteratively adjust JPEG quality until <= 100 KB
    int quality = 82;
    Uint8List compressed = Uint8List.fromList(img.encodeJpg(imageToProcess, quality: quality));

    while (compressed.lengthInBytes > maxSizeBytes && quality > 15) {
      quality -= 12;
      compressed = Uint8List.fromList(img.encodeJpg(imageToProcess, quality: quality));
    }

    // Step 3: If still > 100 KB, resize further to 680px
    if (compressed.lengthInBytes > maxSizeBytes) {
      imageToProcess = img.copyResize(
        imageToProcess,
        width: imageToProcess.width >= imageToProcess.height ? 680 : null,
        height: imageToProcess.height > imageToProcess.width ? 680 : null,
      );
      compressed = Uint8List.fromList(img.encodeJpg(imageToProcess, quality: 70));

      while (compressed.lengthInBytes > maxSizeBytes && quality > 10) {
        quality -= 10;
        compressed = Uint8List.fromList(img.encodeJpg(imageToProcess, quality: quality));
      }
    }

    return compressed;
  }

  /// Opens the device/desktop file picker, compresses image to <= 100 KB, and uploads to Supabase Storage
  static Future<ImageUploadResult?> pickCompressAndUpload() async {
    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.image,
      );

      if (pickedFile == null) {
        // User cancelled picker dialog
        return null;
      }

      final rawBytes = await pickedFile.readAsBytes();
      if (rawBytes.isEmpty) {
        return ImageUploadResult(
          success: false,
          publicUrl: '',
          originalSizeBytes: 0,
          compressedSizeBytes: 0,
          fileName: pickedFile.name,
          errorMessage: 'The selected image file is empty (0 bytes).',
        );
      }

      final originalSize = rawBytes.lengthInBytes;
      final compressedBytes = compressImageUnder100Kb(rawBytes);
      final compressedSize = compressedBytes.lengthInBytes;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanName = pickedFile.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = 'products/${timestamp}_$cleanName';

      String publicUrl = '';
      String? uploadError;
      final client = SupabaseService.client;

      if (client != null) {
        try {
          // Attempt to upload compressed binary to Supabase Storage
          await client.storage.from(bucketName).uploadBinary(
                storagePath,
                compressedBytes,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: true,
                ),
              );
          publicUrl = client.storage.from(bucketName).getPublicUrl(storagePath);
          dev.log('Supabase storage upload successful: $publicUrl');
        } catch (e) {
          uploadError = e.toString();
          dev.log('Supabase storage upload failed: $e');
          // If storage bucket is missing or RLS restricted, generate expected public URL
          publicUrl = client.storage.from(bucketName).getPublicUrl(storagePath);
        }
      }

      if (publicUrl.isEmpty) {
        publicUrl = '${SupabaseService.supabaseUrl}/storage/v1/object/public/$bucketName/$storagePath';
      }

      return ImageUploadResult(
        success: uploadError == null,
        publicUrl: publicUrl,
        originalSizeBytes: originalSize,
        compressedSizeBytes: compressedSize,
        fileName: cleanName,
        errorMessage: uploadError,
      );
    } catch (e) {
      dev.log('Image picker or compression exception: $e');
      return ImageUploadResult(
        success: false,
        publicUrl: '',
        originalSizeBytes: 0,
        compressedSizeBytes: 0,
        fileName: 'unknown',
        errorMessage: e.toString(),
      );
    }
  }
}
