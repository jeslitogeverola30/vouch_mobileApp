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
        .select(
          'student_id, full_name, email, faculty, program, account_status, profile_photo_url',
        )
        .order('full_name', ascending: true);

    final adminEmails = await _fetchAdminEmails();

    final studentRows = List<Map<String, dynamic>>.from(response).where((row) {
      final email = _normalizeEmail(row['email']);
      if (email.isEmpty) {
        return true;
      }

      return !adminEmails.contains(email);
    });

    return studentRows.map(_mapStudent).toList();
  }

  @override
  Future<void> freezeStudents(List<String> studentIds) async {
    final normalizedIds = _normalizeStudentIds(studentIds);
    if (normalizedIds.isEmpty) {
      return;
    }

    await _client
        .from('students')
        .update({'account_status': 'frozen'})
        .inFilter('student_id', normalizedIds);
  }

  @override
  Future<void> activateStudents(List<String> studentIds) async {
    final normalizedIds = _normalizeStudentIds(studentIds);
    if (normalizedIds.isEmpty) {
      return;
    }

    await _client
        .from('students')
        .update({'account_status': 'active'})
        .inFilter('student_id', normalizedIds);
  }

  @override
  Future<void> deleteStudents(List<String> studentIds) async {
    final normalizedIds = _normalizeStudentIds(studentIds);
    if (normalizedIds.isEmpty) {
      return;
    }

    await _client
        .from('students')
        .delete()
        .inFilter('student_id', normalizedIds);
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
    final status = _normalizeStatus(
      _readString(data['account_status']).isNotEmpty
          ? _readString(data['account_status'])
          : _readString(data['status']),
    );
    final program = _readString(data['program']).isNotEmpty
        ? _readString(data['program'])
        : _readString(data['faculty']);

    return StudentEntity(
      studentId: _readString(data['student_id']),
      name: normalizedName,
      email: _readString(data['email']),
      program: program,
      status: status,
      initials: _extractInitials(normalizedName),
      avatarUrl: _readString(data['profile_photo_url']),
    );
  }

  String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  String _normalizeEmail(dynamic value) {
    return _readString(value).toLowerCase();
  }

  Future<Set<String>> _fetchAdminEmails() async {
    try {
      final response = await _client.from('admins').select('email');

      return List<Map<String, dynamic>>.from(response)
          .map((row) => _normalizeEmail(row['email']))
          .where((email) => email.isNotEmpty)
          .toSet();
    } catch (_) {
      return const <String>{};
    }
  }

  List<String> _normalizeStudentIds(List<String> studentIds) {
    return studentIds
        .map(_readString)
        .where((studentId) => studentId.isNotEmpty)
        .toSet()
        .toList();
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

  String _normalizeStatus(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'frozen':
        return 'Frozen';
      default:
        if (normalized.isEmpty) {
          return 'Active';
        }

        if (normalized.length == 1) {
          return normalized.toUpperCase();
        }

        return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
    }
  }
}
