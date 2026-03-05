import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryClient {
  CloudinaryClient._();

  static String? get cloudName => _normalizedEnv('CLOUDINARY_CLOUD_NAME');
  static String? get uploadPreset => _normalizedEnv('CLOUDINARY_UPLOAD_PRESET');

  static bool get isConfigured =>
      cloudName != null &&
      cloudName!.isNotEmpty &&
      uploadPreset != null &&
      uploadPreset!.isNotEmpty;

  static Uri get imageUploadUri {
    if (!isConfigured) {
      throw StateError(
        'Missing CLOUDINARY_CLOUD_NAME or CLOUDINARY_UPLOAD_PRESET in .env file.',
      );
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
