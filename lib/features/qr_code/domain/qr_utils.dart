import 'dart:convert';

import 'qr_payload_entity.dart';

class QrUtils {
  const QrUtils._();

  static String encode(String value) {
    return value;
  }

  static String decode(String value) {
    return value;
  }

  static String generateStudentQrPayload({
    required String studentId,
    required String fullName,
    required String faculty,
    required String program,
  }) {
    final payload = QrPayloadEntity(
      studentId: studentId,
      fullName: fullName,
      faculty: faculty,
      program: program,
    );

    return jsonEncode(payload.toMap());
  }

  static String initialsFromName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'ST';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
