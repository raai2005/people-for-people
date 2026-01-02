import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  late final String _cloudName;
  late final String _apiKey;
  late final String _apiSecret;
  late final String _uploadPreset;

  CloudinaryService() {
    _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    _apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
    _apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
    _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    if (_cloudName.isEmpty ||
        _apiKey.isEmpty ||
        _apiSecret.isEmpty ||
        _uploadPreset.isEmpty) {
      throw Exception(
        'Cloudinary credentials not found in .env file. '
        'Please ensure CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, '
        'CLOUDINARY_API_SECRET, and CLOUDINARY_UPLOAD_PRESET are set.',
      );
    }
  }

  /// Upload an image file to Cloudinary and return the secure URL
  /// Works on all platforms (web, mobile, desktop) by accepting bytes
  Future<String> uploadImage(Uint8List imageBytes, String filename) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add the image file from bytes
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
      );

      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = _uploadPreset;

      // Add timestamp for signed upload (optional, but recommended)
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      request.fields['timestamp'] = timestamp;

      // Add API key
      request.fields['api_key'] = _apiKey;

      // Generate signature for secure upload
      final signature = _generateSignature(timestamp);
      request.fields['signature'] = signature;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final secureUrl = responseData['secure_url'] as String;
        return secureUrl;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Cloudinary upload failed: ${errorData['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network error occurred. Please check your connection and try again.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload a document file (PDF or image) to Cloudinary and return the secure URL
  /// Works on all platforms (web, mobile, desktop) by accepting bytes
  Future<String> uploadDocument(
    Uint8List documentBytes,
    String filename,
  ) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload',
      );

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add the document file from bytes
      request.files.add(
        http.MultipartFile.fromBytes('file', documentBytes, filename: filename),
      );

      // Add upload preset (unsigned upload)
      request.fields['upload_preset'] = _uploadPreset;

      // Add timestamp for signed upload (optional, but recommended)
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      request.fields['timestamp'] = timestamp;

      // Add API key
      request.fields['api_key'] = _apiKey;

      // Generate signature for secure upload
      final signature = _generateSignature(timestamp);
      request.fields['signature'] = signature;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final secureUrl = responseData['secure_url'] as String;
        return secureUrl;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Cloudinary upload failed: ${errorData['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } on http.ClientException {
      throw Exception(
        'Network error occurred. Please check your connection and try again.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Generate signature for Cloudinary signed upload
  String _generateSignature(String timestamp) {
    // Create the string to sign
    final paramsToSign =
        'timestamp=$timestamp&upload_preset=$_uploadPreset$_apiSecret';

    // Generate SHA-1 hash
    final bytes = utf8.encode(paramsToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
