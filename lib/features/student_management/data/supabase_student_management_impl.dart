import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/attendance_record_entity.dart';
import '../domain/student_management_repository.dart';
import '../domain/student_entity.dart';

class SupabaseStudentManagementImpl implements StudentManagementRepository {
  SupabaseStudentManagementImpl._();

  static final SupabaseStudentManagementImpl instance =
      SupabaseStudentManagementImpl._();

  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<StudentEntity>> fetchStudents() async {
    final response = await _client
        .from('students')
        .select('student_id, full_name, email, faculty, program')
        .order('full_name', ascending: true);

    return List<Map<String, dynamic>>.from(response).map(_mapStudent).toList();
  }

  @override
  Future<List<AttendanceRecordEntity>> fetchAttendanceRecords() async {
    final response = await _client
        .from('event_attendance')
        .select('student_id, student_name, event_name, status, recorded_at')
        .order('recorded_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(_mapAttendanceRecord).toList();
  }

  AttendanceRecordEntity _mapAttendanceRecord(Map<String, dynamic> data) {
    final recordedAtRaw = data['recorded_at'];

    return AttendanceRecordEntity(
      studentId: (data['student_id'] as String? ?? '').trim(),
      studentName: (data['student_name'] as String? ?? '').trim(),
      eventName: (data['event_name'] as String? ?? '').trim(),
      status: (data['status'] as String? ?? '').trim(),
      recordedAt:
          DateTime.tryParse(recordedAtRaw?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  StudentEntity _mapStudent(Map<String, dynamic> data) {
    final fullName = _readString(data['full_name']).isNotEmpty
        ? _readString(data['full_name'])
        : _readString(data['name']);
    final normalizedName = fullName.isEmpty ? 'Unknown Student' : fullName;
    final status = _readString(data['status']);
    final program = _readString(data['program']).isNotEmpty
        ? _readString(data['program'])
        : _readString(data['faculty']);

    return StudentEntity(
      studentId: _readString(data['student_id']),
      name: normalizedName,
      email: _readString(data['email']),
      program: program,
      status: status.isEmpty ? 'Active' : status,
      initials: _extractInitials(normalizedName),
    );
  }

  String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  String _extractInitials(String fullName) {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'ST';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
