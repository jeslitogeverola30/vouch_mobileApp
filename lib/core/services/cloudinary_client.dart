import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryClient {
  CloudinaryClient._();

  static String? get cloudName => _normalizedEnv('CLOUDINARY_CLOUD_NAME');
  static String? get uploadPreset => _normalizedEnv('CLOUDINARY_UPLOAD_PRESET');
  static String? get profileUploadPreset =>
      _normalizedEnv('CLOUDINARY_PROFILE_UPLOAD_PRESET');
  static String? get receiptUploadPreset =>
      _normalizedEnv('CLOUDINARY_RECEIPT_UPLOAD_PRESET');

  static bool get isCloudConfigured =>
      cloudName != null && cloudName!.isNotEmpty;

  static bool get isEventUploadConfigured =>
      isCloudConfigured && uploadPreset != null && uploadPreset!.isNotEmpty;

  static bool get isProfileUploadConfigured =>
      isCloudConfigured &&
      profileUploadPreset != null &&
      profileUploadPreset!.isNotEmpty;

  static bool get isReceiptUploadConfigured =>
      isCloudConfigured &&
      receiptUploadPreset != null &&
      receiptUploadPreset!.isNotEmpty;

  static bool get isConfigured => isEventUploadConfigured;

  static Uri get imageUploadUri {
    if (!isCloudConfigured) {
      throw StateError('Missing CLOUDINARY_CLOUD_NAME in .env file.');
    }

    return Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
  }

  static String? _normalizedEnv(String key) {
    var value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    final wrappedInSingleQuotes =
        value.length >= 2 && value.startsWith("'") && value.endsWith("'");
    final wrappedInDoubleQuotes =
        value.length >= 2 && value.startsWith('"') && value.endsWith('"');

    if (wrappedInSingleQuotes || wrappedInDoubleQuotes) {
      value = value.substring(1, value.length - 1).trim();
    }

    if (value.isEmpty) {
      return null;
    }

    return value;
  }
}
