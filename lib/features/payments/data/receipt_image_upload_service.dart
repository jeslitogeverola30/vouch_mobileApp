import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/services/cloudinary_client.dart';

class ReceiptImageUploadService {
  ReceiptImageUploadService._();

  static Future<String> uploadReceiptImage({required File imageFile}) async {
    final uploadPreset = CloudinaryClient.receiptUploadPreset;
    if (uploadPreset == null || uploadPreset.trim().isEmpty) {
      throw StateError(
        'Missing CLOUDINARY_RECEIPT_UPLOAD_PRESET in .env file.',
      );
    }

    final request =
        http.MultipartRequest('POST', CloudinaryClient.imageUploadUri)
          ..fields['upload_preset'] = uploadPreset
          ..fields['folder'] = 'receipts'
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();
    final payload = _decodeJsonBody(responseBody);

    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      final errorMessage = _extractCloudinaryError(payload);
      throw Exception(
        errorMessage ?? 'Failed to upload receipt image to Cloudinary.',
      );
    }

    final secureUrl = payload['secure_url'];
    if (secureUrl is String && secureUrl.trim().isNotEmpty) {
      return secureUrl.trim();
    }

    throw Exception(
      'Cloudinary upload succeeded but no secure_url was returned.',
    );
  }

  static Map<String, dynamic> _decodeJsonBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static String? _extractCloudinaryError(Map<String, dynamic> payload) {
    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.trim().isNotEmpty) {
        return _friendlyCloudinaryError(message.trim());
      }
    }

    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) {
      return _friendlyCloudinaryError(message.trim());
    }

    return null;
  }

  static String _friendlyCloudinaryError(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('whitelisted for unsigned uploads') ||
        (normalized.contains('unsigned') &&
            normalized.contains('upload preset'))) {
      return 'Cloudinary receipt preset is not configured for unsigned uploads. Open Cloudinary Dashboard → Settings → Upload → Upload presets, edit your receipt preset, set Signing mode to Unsigned, and save.';
    }

    if (normalized.contains('upload preset must be specified') ||
        normalized.contains('upload_preset')) {
      return 'Receipt upload preset is invalid or missing. Check CLOUDINARY_RECEIPT_UPLOAD_PRESET in .env.';
    }

    if (normalized.contains('unknown api key') ||
        normalized.contains('invalid cloud name')) {
      return 'Cloudinary cloud configuration is invalid. Check CLOUDINARY_CLOUD_NAME in .env.';
    }

    return message;
  }
}
