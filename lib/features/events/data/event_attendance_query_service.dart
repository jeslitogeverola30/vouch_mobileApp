import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/event_attendance.dart';

class EventAttendanceQueryService {
  EventAttendanceQueryService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static const String _attendanceTable = 'event_attendance';
  static const String _studentsTable = 'students';

  static Future<List<StudentAttendance>> fetchEventStudents({
    required int eventId,
    required bool isEventDone,
  }) async {
    final studentsRows = await _fetchAllStudentRows();

    final attendanceResponse = await _client
        .from(_attendanceTable)
        .select('student_id, scanned_time_in, scanned_time_out, status')
        .eq('event_id', eventId);

    final attendanceRows = List<Map<String, dynamic>>.from(attendanceResponse);

    final attendanceByStudentId = <String, _AttendanceSnapshot>{};
    for (final attendanceRow in attendanceRows) {
      final studentId = _readString(attendanceRow['student_id']);
      if (studentId.isEmpty) {
        continue;
      }

      final nextSnapshot = _AttendanceSnapshot(
        scannedTimeIn: _parseDateTime(attendanceRow['scanned_time_in']),
        scannedTimeOut: _parseDateTime(attendanceRow['scanned_time_out']),
        status: _readString(attendanceRow['status']),
      );

      final previousSnapshot = attendanceByStudentId[studentId];
      attendanceByStudentId[studentId] = previousSnapshot == null
          ? nextSnapshot
          : previousSnapshot.merge(nextSnapshot);
    }

    final students = studentsRows.map((studentRow) {
      final studentId = _readString(studentRow['student_id']);
      final attendanceSnapshot = attendanceByStudentId[studentId];

      final scannedTimeIn = attendanceSnapshot?.scannedTimeIn;
      final scannedTimeOut = attendanceSnapshot?.scannedTimeOut;
      final hasTimeIn = scannedTimeIn != null;
      final hasTimeOut = scannedTimeOut != null;

      final status = _resolveStatus(
        rawStatus: attendanceSnapshot?.status ?? '',
        hasTimeIn: hasTimeIn,
        hasTimeOut: hasTimeOut,
        isEventDone: isEventDone,
      );

      return StudentAttendance(
        id: studentId.isEmpty ? '-' : studentId,
        name: _readString(studentRow['full_name']).isEmpty
            ? 'Student'
            : _readString(studentRow['full_name']),
        program: _readString(studentRow['program']).isEmpty
            ? 'N/A'
            : _readString(studentRow['program']),
        timeIn: hasTimeIn ? _formatDisplayTime(scannedTimeIn.toLocal()) : null,
        timeOut: hasTimeOut
            ? _formatDisplayTime(scannedTimeOut.toLocal())
            : null,
        status: status,
        avatarUrl: _readString(studentRow['profile_photo_url']),
      );
    }).toList();

    final existingStudentIds = students
        .map((student) => student.id)
        .where((studentId) => studentId.isNotEmpty)
        .toSet();

    for (final entry in attendanceByStudentId.entries) {
      if (existingStudentIds.contains(entry.key)) {
        continue;
      }

      final scannedTimeIn = entry.value.scannedTimeIn;
      final scannedTimeOut = entry.value.scannedTimeOut;
      final hasTimeIn = scannedTimeIn != null;
      final hasTimeOut = scannedTimeOut != null;

      students.add(
        StudentAttendance(
          id: entry.key,
          name: 'Student',
          program: 'N/A',
          timeIn: hasTimeIn
              ? _formatDisplayTime(scannedTimeIn.toLocal())
              : null,
          timeOut: hasTimeOut
              ? _formatDisplayTime(scannedTimeOut.toLocal())
              : null,
          status: _resolveStatus(
            rawStatus: entry.value.status,
            hasTimeIn: hasTimeIn,
            hasTimeOut: hasTimeOut,
            isEventDone: isEventDone,
          ),
          avatarUrl: '',
        ),
      );
    }

    students.sort((first, second) {
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });

    return students;
  }

  static String _resolveStatus({
    required String rawStatus,
    required bool hasTimeIn,
    required bool hasTimeOut,
    required bool isEventDone,
  }) {
    if (isEventDone) {
      return hasTimeIn && hasTimeOut
          ? EventAttendanceStatus.present
          : EventAttendanceStatus.absent;
    }

    final normalizedStatus = rawStatus.toLowerCase();
    if (normalizedStatus == 'absent') {
      return EventAttendanceStatus.absent;
    }

    if (normalizedStatus == 'present' || normalizedStatus == 'completed') {
      return EventAttendanceStatus.present;
    }

    if (hasTimeIn || hasTimeOut) {
      return EventAttendanceStatus.present;
    }

    return EventAttendanceStatus.absent;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = _readString(value);
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String _formatDisplayTime(DateTime value) {
    final hour24 = value.hour;
    final minuteText = value.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }

  static Future<List<Map<String, dynamic>>> _fetchAllStudentRows() async {
    const int pageSize = 1000;
    var start = 0;
    final allRows = <Map<String, dynamic>>[];

    while (true) {
      final response = await _client
          .from(_studentsTable)
          .select('student_id, full_name, program, profile_photo_url')
          .order('student_id', ascending: true)
          .range(start, start + pageSize - 1);

      final pageRows = List<Map<String, dynamic>>.from(response);
      if (pageRows.isEmpty) {
        break;
      }

      allRows.addAll(pageRows);
      if (pageRows.length < pageSize) {
        break;
      }

      start += pageSize;
    }

    return allRows;
  }
}

class _AttendanceSnapshot {
  const _AttendanceSnapshot({
    required this.scannedTimeIn,
    required this.scannedTimeOut,
    required this.status,
  });

  final DateTime? scannedTimeIn;
  final DateTime? scannedTimeOut;
  final String status;

  _AttendanceSnapshot merge(_AttendanceSnapshot other) {
    return _AttendanceSnapshot(
      scannedTimeIn: _earliest(scannedTimeIn, other.scannedTimeIn),
      scannedTimeOut: _latest(scannedTimeOut, other.scannedTimeOut),
      status: status.isNotEmpty ? status : other.status,
    );
  }

  DateTime? _earliest(DateTime? first, DateTime? second) {
    if (first == null) {
      return second;
    }

    if (second == null) {
      return first;
    }

    return first.isBefore(second) ? first : second;
  }

  DateTime? _latest(DateTime? first, DateTime? second) {
    if (first == null) {
      return second;
    }

    if (second == null) {
      return first;
    }

    return first.isAfter(second) ? first : second;
  }
}
