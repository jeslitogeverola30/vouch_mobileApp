import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../../profile/data/supabase_profile_repository_impl.dart';

class StudentHomeStatistics {
  const StudentHomeStatistics({
    required this.attendanceRate,
    required this.upcomingEventsCount,
  });

  final double attendanceRate;
  final int upcomingEventsCount;
}

class StudentHomeStatisticsService {
  StudentHomeStatisticsService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static const String _eventsTable = 'events';
  static const String _attendanceTable = 'event_attendance';
  static const String _studentsTable = 'students';

  static Future<StudentHomeStatistics> fetchStatistics() async {
    final todayDate = _databaseDate(DateTime.now());

    final upcomingEventsResponse = await _client
        .from(_eventsTable)
        .select('id')
        .gt('event_date', todayDate);

    final upcomingEventsCount = List<Map<String, dynamic>>.from(
      upcomingEventsResponse,
    ).length;

    final pastEventsResponse = await _client
        .from(_eventsTable)
        .select('id')
        .lt('event_date', todayDate);

    final pastEventRows = List<Map<String, dynamic>>.from(pastEventsResponse);
    final totalPastEvents = pastEventRows.length;

    if (totalPastEvents == 0) {
      return StudentHomeStatistics(
        attendanceRate: 0,
        upcomingEventsCount: upcomingEventsCount,
      );
    }

    final studentId = await _resolveCurrentStudentId();
    if (studentId.isEmpty) {
      return StudentHomeStatistics(
        attendanceRate: 0,
        upcomingEventsCount: upcomingEventsCount,
      );
    }

    final pastEventIds = pastEventRows
        .map((row) => _readInt(row['id']))
        .whereType<int>()
        .toList();

    if (pastEventIds.isEmpty) {
      return StudentHomeStatistics(
        attendanceRate: 0,
        upcomingEventsCount: upcomingEventsCount,
      );
    }

    final attendanceResponse = await _client
        .from(_attendanceTable)
        .select('event_id, scanned_time_in, scanned_time_out')
        .eq('student_id', studentId)
        .inFilter('event_id', pastEventIds);

    final attendanceRows = List<Map<String, dynamic>>.from(attendanceResponse);
    final attendanceByEventId = <int, _AttendanceSnapshot>{};

    for (final row in attendanceRows) {
      final eventId = _readInt(row['event_id']);
      if (eventId == null) {
        continue;
      }

      final hasTimeIn = _parseDateTime(row['scanned_time_in']) != null;
      final hasTimeOut = _parseDateTime(row['scanned_time_out']) != null;

      final previous = attendanceByEventId[eventId];
      attendanceByEventId[eventId] = previous == null
          ? _AttendanceSnapshot(hasTimeIn: hasTimeIn, hasTimeOut: hasTimeOut)
          : previous.merge(hasTimeIn: hasTimeIn, hasTimeOut: hasTimeOut);
    }

    double attendedEquivalent = 0;
    for (final snapshot in attendanceByEventId.values) {
      if (snapshot.hasTimeIn && snapshot.hasTimeOut) {
        attendedEquivalent += 1;
      } else if (snapshot.hasTimeIn || snapshot.hasTimeOut) {
        attendedEquivalent += 0.5;
      }
    }

    final attendanceRate = (attendedEquivalent / totalPastEvents) * 100;

    return StudentHomeStatistics(
      attendanceRate: attendanceRate,
      upcomingEventsCount: upcomingEventsCount,
    );
  }

  static Future<String> _resolveCurrentStudentId() async {
    try {
      final profile = await SupabaseProfileRepositoryImpl.instance
          .getCurrentUserProfile();
      final fromProfile = profile?.studentId.trim() ?? '';
      if (fromProfile.isNotEmpty) {
        return fromProfile;
      }
    } catch (_) {}

    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return '';
    }

    final student = await _client
        .from(_studentsTable)
        .select('student_id')
        .ilike('email', email)
        .maybeSingle();

    return _readString(student?['student_id']);
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = _readString(value);
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String _databaseDate(DateTime value) {
    final dateOnly = DateTime(value.year, value.month, value.day);
    final year = dateOnly.year.toString().padLeft(4, '0');
    final month = dateOnly.month.toString().padLeft(2, '0');
    final day = dateOnly.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _AttendanceSnapshot {
  const _AttendanceSnapshot({
    required this.hasTimeIn,
    required this.hasTimeOut,
  });

  final bool hasTimeIn;
  final bool hasTimeOut;

  _AttendanceSnapshot merge({
    required bool hasTimeIn,
    required bool hasTimeOut,
  }) {
    return _AttendanceSnapshot(
      hasTimeIn: this.hasTimeIn || hasTimeIn,
      hasTimeOut: this.hasTimeOut || hasTimeOut,
    );
  }
}
