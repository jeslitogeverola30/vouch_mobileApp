import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/qr_scan_record_entity.dart';

enum AttendanceScanMode { timeIn, timeOut }

class AttendanceScanResult {
  const AttendanceScanResult({
    required this.success,
    required this.alreadyScanned,
    required this.message,
    this.scannedAt,
  });

  final bool success;
  final bool alreadyScanned;
  final String message;
  final DateTime? scannedAt;
}

class EventAttendanceSummary {
  const EventAttendanceSummary({
    required this.totalScans,
    required this.recentScans,
  });

  final int totalScans;
  final List<QrScanRecordEntity> recentScans;
}

class QrEventAttendanceService {
  QrEventAttendanceService._();

  static final QrEventAttendanceService instance = QrEventAttendanceService._();

  final SupabaseClient _client = Supabase.instance.client;

  static const String _attendanceTable = 'event_attendance';
  static const String _studentsTable = 'students';

  Future<AttendanceScanResult> recordScan({
    required int eventId,
    required String studentId,
    required AttendanceScanMode mode,
  }) async {
    final normalizedStudentId = studentId.trim();
    if (normalizedStudentId.isEmpty) {
      return const AttendanceScanResult(
        success: false,
        alreadyScanned: false,
        message: 'Student ID is missing from QR payload.',
      );
    }

    try {
      final existing = await _client
          .from(_attendanceTable)
          .select('scanned_time_in, scanned_time_out')
          .eq('event_id', eventId)
          .eq('student_id', normalizedStudentId)
          .maybeSingle();

      final now = DateTime.now().toUtc();
      final nowIso = now.toIso8601String();

      if (existing == null) {
        final insertPayload = <String, dynamic>{
          'event_id': eventId,
          'student_id': normalizedStudentId,
          'status': 'pending',
        };

        if (mode == AttendanceScanMode.timeIn) {
          insertPayload['scanned_time_in'] = nowIso;
        } else {
          insertPayload['scanned_time_out'] = nowIso;
        }

        await _client.from(_attendanceTable).insert(insertPayload);

        return AttendanceScanResult(
          success: true,
          alreadyScanned: false,
          scannedAt: now,
          message: mode == AttendanceScanMode.timeIn
              ? 'Time In recorded successfully.'
              : 'Time Out recorded successfully.',
        );
      }

      final hasTimeIn = _parseDateTime(existing['scanned_time_in']) != null;
      final hasTimeOut = _parseDateTime(existing['scanned_time_out']) != null;

      if (mode == AttendanceScanMode.timeIn && hasTimeIn) {
        return const AttendanceScanResult(
          success: false,
          alreadyScanned: true,
          message: 'This student already has a Time In scan for this event.',
        );
      }

      if (mode == AttendanceScanMode.timeOut && hasTimeOut) {
        return const AttendanceScanResult(
          success: false,
          alreadyScanned: true,
          message: 'This student already has a Time Out scan for this event.',
        );
      }

      final updatePayload = <String, dynamic>{
        if (mode == AttendanceScanMode.timeIn) 'scanned_time_in': nowIso,
        if (mode == AttendanceScanMode.timeOut) 'scanned_time_out': nowIso,
      };

      final nextHasTimeIn = hasTimeIn || mode == AttendanceScanMode.timeIn;
      final nextHasTimeOut = hasTimeOut || mode == AttendanceScanMode.timeOut;
      updatePayload['status'] = nextHasTimeIn && nextHasTimeOut
          ? 'completed'
          : 'pending';

      await _client
          .from(_attendanceTable)
          .update(updatePayload)
          .eq('event_id', eventId)
          .eq('student_id', normalizedStudentId);

      return AttendanceScanResult(
        success: true,
        alreadyScanned: false,
        scannedAt: now,
        message: mode == AttendanceScanMode.timeIn
            ? 'Time In updated successfully.'
            : 'Time Out updated successfully.',
      );
    } on PostgrestException catch (error) {
      final message = error.message.trim();
      return AttendanceScanResult(
        success: false,
        alreadyScanned: false,
        message: message.isEmpty
            ? 'Failed to save attendance record.'
            : message,
      );
    } catch (_) {
      return const AttendanceScanResult(
        success: false,
        alreadyScanned: false,
        message: 'Failed to save attendance record. Please try again.',
      );
    }
  }

  Future<EventAttendanceSummary> fetchEventAttendanceSummary({
    required int eventId,
    int recentLimit = 12,
  }) async {
    final response = await _client
        .from(_attendanceTable)
        .select('student_id, scanned_time_in, scanned_time_out')
        .eq('event_id', eventId);

    final attendanceRows = List<Map<String, dynamic>>.from(response);

    final uniqueStudentIds = attendanceRows
        .map((row) => row['student_id']?.toString().trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final studentsById = <String, Map<String, dynamic>>{};
    if (uniqueStudentIds.isNotEmpty) {
      final studentsResponse = await _client
          .from(_studentsTable)
          .select('student_id, full_name, program')
          .inFilter('student_id', uniqueStudentIds);

      final studentsRows = List<Map<String, dynamic>>.from(studentsResponse);
      for (final row in studentsRows) {
        final studentId = row['student_id']?.toString().trim() ?? '';
        if (studentId.isNotEmpty) {
          studentsById[studentId] = row;
        }
      }
    }

    final timeline = <_ScanTimelineRecord>[];

    for (final row in attendanceRows) {
      final studentId = row['student_id']?.toString().trim() ?? '';
      if (studentId.isEmpty) {
        continue;
      }

      final student = studentsById[studentId];
      final fullName = student?['full_name']?.toString().trim() ?? studentId;
      final program = student?['program']?.toString().trim() ?? 'N/A';

      final timeIn = _parseDateTime(row['scanned_time_in']);
      final timeOut = _parseDateTime(row['scanned_time_out']);

      if (timeIn != null) {
        timeline.add(
          _ScanTimelineRecord(
            studentId: studentId,
            fullName: fullName,
            program: program,
            scannedAt: timeIn,
            type: 'Time In',
          ),
        );
      }

      if (timeOut != null) {
        timeline.add(
          _ScanTimelineRecord(
            studentId: studentId,
            fullName: fullName,
            program: program,
            scannedAt: timeOut,
            type: 'Time Out',
          ),
        );
      }
    }

    timeline.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

    final recentScans = timeline
        .take(recentLimit)
        .map(
          (record) => QrScanRecordEntity(
            name: record.fullName,
            studentId: record.studentId,
            program: record.program,
            time: _formatDisplayTime(record.scannedAt.toLocal()),
            status: 'success',
            type: record.type,
          ),
        )
        .toList();

    return EventAttendanceSummary(
      totalScans: attendanceRows.length,
      recentScans: recentScans,
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  String _formatDisplayTime(DateTime dateTime) {
    final hour24 = dateTime.hour;
    final minuteText = dateTime.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }
}

class _ScanTimelineRecord {
  const _ScanTimelineRecord({
    required this.studentId,
    required this.fullName,
    required this.program,
    required this.scannedAt,
    required this.type,
  });

  final String studentId;
  final String fullName;
  final String program;
  final DateTime scannedAt;
  final String type;
}
