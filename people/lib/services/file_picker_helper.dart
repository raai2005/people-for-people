import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FilePickerHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick a document (PDF or image) from device
  /// Returns Uint8List of file bytes and filename
  static Future<({Uint8List bytes, String filename})?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true, // Important for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          // Web or when bytes are available
          return (bytes: file.bytes!, filename: file.name);
        } else if (file.path != null && !kIsWeb) {
          // Mobile/Desktop - read file from path
          final bytes = await _readFileBytes(file.path!);
          return (bytes: bytes, filename: file.name);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick document: $e');
    }
  }

  /// Pick an image from camera or gallery
  /// Returns Uint8List of image bytes and filename
  static Future<({Uint8List bytes, String filename})?> pickImage({
    required ImageSource source,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        return (bytes: bytes, filename: image.name);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Show dialog to choose between camera and gallery
  /// Returns picked image bytes and filename
  static Future<({Uint8List bytes, String filename})?> pickImageWithDialog({
    required Future<ImageSource?> Function() showSourceDialog,
  }) async {
    final source = await showSourceDialog();
    if (source == null) return null;

    return await pickImage(source: source);
  }

  /// Helper method to read file bytes from path (for mobile/desktop)
  static Future<Uint8List> _readFileBytes(String path) async {
    // This will be handled by file_picker's bytes property
    // or by reading from path on mobile
    throw UnimplementedError('Use file.bytes from FilePicker');
  }
}
