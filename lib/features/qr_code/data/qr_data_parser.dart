import 'dart:convert';

import '../domain/qr_payload_entity.dart';

class QrDataParser {
  const QrDataParser();

  QrPayloadEntity? parse(String rawValue) {
    final normalized = rawValue.trim();
    if (normalized.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(normalized);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final payload = QrPayloadEntity(
        studentId: _readString(decoded['student_id']),
        fullName: _readString(decoded['full_name']),
        faculty: _readString(decoded['faculty']),
        program: _readString(decoded['program']),
      );

      return payload.isValid ? payload : null;
    } catch (_) {
      return null;
    }
  }

  String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
