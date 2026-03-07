import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../../profile/data/supabase_profile_repository_impl.dart';
import '../domain/event_date_time_formatters.dart';

class EventQueryService {
  EventQueryService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static const String _eventsTable = 'events';
  static const String _attendanceTable = 'event_attendance';
  static const String _studentsTable = 'students';

  static Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await _client
        .from(_eventsTable)
        .select(
          'id, name, short_description, full_description, location, image_url, event_date, schedule_time_in_start, schedule_time_in_end, schedule_time_out_start, schedule_time_out_end, is_mandatory',
        )
        .order('event_date', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response);

    return rows.map(_mapEventRow).toList();
  }

  static Future<List<Map<String, dynamic>>>
  fetchEventsForCurrentStudent() async {
    final events = await fetchEvents();
    if (events.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final studentId = await _resolveCurrentStudentIdOrEmpty();
    if (studentId.isEmpty) {
      return events.map(_withNoStudentAttendance).toList();
    }

    final eventIds = events
        .map((event) => _readInt(event['id']))
        .whereType<int>()
        .toSet()
        .toList();
    if (eventIds.isEmpty) {
      return events.map(_withNoStudentAttendance).toList();
    }

    try {
      final response = await _client
          .from(_attendanceTable)
          .select('event_id, scanned_time_in, scanned_time_out, status')
          .eq('student_id', studentId)
          .inFilter('event_id', eventIds);

      final attendanceRows = List<Map<String, dynamic>>.from(response);
      final attendanceByEventId = <int, _StudentAttendanceSnapshot>{};

      for (final row in attendanceRows) {
        final eventId = _readInt(row['event_id']);
        if (eventId == null) {
          continue;
        }

        final nextSnapshot = _StudentAttendanceSnapshot(
          scannedTimeIn: _parseDateTime(row['scanned_time_in']),
          scannedTimeOut: _parseDateTime(row['scanned_time_out']),
          status: _readString(row['status']).toLowerCase(),
        );

        final previousSnapshot = attendanceByEventId[eventId];
        attendanceByEventId[eventId] = previousSnapshot == null
            ? nextSnapshot
            : previousSnapshot.merge(nextSnapshot);
      }

      return events.map((event) {
        final eventId = _readInt(event['id']);
        final snapshot = eventId == null ? null : attendanceByEventId[eventId];

        final studentTimeIn = snapshot?.scannedTimeIn == null
            ? null
            : _formatDisplayClock(snapshot!.scannedTimeIn!.toLocal());
        final studentTimeOut = snapshot?.scannedTimeOut == null
            ? null
            : _formatDisplayClock(snapshot!.scannedTimeOut!.toLocal());

        final hasTimeIn = studentTimeIn != null;
        final hasTimeOut = studentTimeOut != null;
        final attended =
            (hasTimeIn && hasTimeOut) || snapshot?.status == 'completed';

        return {
          ...event,
          'attended': attended,
          'studentTimeIn': studentTimeIn,
          'studentTimeOut': studentTimeOut,
        };
      }).toList();
    } catch (_) {
      return events.map(_withNoStudentAttendance).toList();
    }
  }

  static List<Map<String, dynamic>> todayEvents(
    List<Map<String, dynamic>> events,
  ) {
    final today = _dateOnly(DateTime.now());

    final todayEvents = events
        .where(
          (event) =>
              _eventDateValue(event) != null &&
              _eventDateValue(event)!.isAtSameMomentAs(today),
        )
        .toList();

    todayEvents.sort(
      (first, second) =>
          _eventDateValue(first)!.compareTo(_eventDateValue(second)!),
    );

    return todayEvents;
  }

  static List<Map<String, dynamic>> upcomingEvents(
    List<Map<String, dynamic>> events,
  ) {
    final today = _dateOnly(DateTime.now());

    final upcomingEvents = events
        .where(
          (event) =>
              _eventDateValue(event) != null &&
              _eventDateValue(event)!.isAfter(today),
        )
        .toList();

    upcomingEvents.sort(
      (first, second) =>
          _eventDateValue(first)!.compareTo(_eventDateValue(second)!),
    );

    return upcomingEvents;
  }

  static List<Map<String, dynamic>> pastEvents(
    List<Map<String, dynamic>> events,
  ) {
    final today = _dateOnly(DateTime.now());

    final pastEvents = events
        .where(
          (event) =>
              _eventDateValue(event) != null &&
              _eventDateValue(event)!.isBefore(today),
        )
        .toList();

    pastEvents.sort(
      (first, second) =>
          _eventDateValue(second)!.compareTo(_eventDateValue(first)!),
    );

    return pastEvents;
  }

  static Map<String, dynamic> _mapEventRow(Map<String, dynamic> row) {
    final parsedDate = _parseDate(row['event_date']) ?? DateTime.now();
    final imageUrl = _readString(row['image_url']);
    final fullDescription = _readString(row['full_description']);
    final shortDescription = _readString(row['short_description']);

    return {
      'id': row['id'],
      'name': _readString(row['name']).isEmpty
          ? 'Event'
          : _readString(row['name']),
      'date': EventDateTimeFormatters.displayDate(parsedDate),
      'timeIn': _formatTimeRange(
        row['schedule_time_in_start'],
        row['schedule_time_in_end'],
      ),
      'timeOut': _formatTimeRange(
        row['schedule_time_out_start'],
        row['schedule_time_out_end'],
      ),
      'eventDateRaw': EventDateTimeFormatters.databaseDate(parsedDate),
      'timeInStartRaw': _readString(row['schedule_time_in_start']),
      'timeInEndRaw': _readString(row['schedule_time_in_end']),
      'timeOutStartRaw': _readString(row['schedule_time_out_start']),
      'timeOutEndRaw': _readString(row['schedule_time_out_end']),
      'image': imageUrl.isEmpty ? 'assets/images/event-siglakas.jpg' : imageUrl,
      'isObligatory': row['is_mandatory'] == true,
      'location': _readString(row['location']).isEmpty
          ? 'University Campus'
          : _readString(row['location']),
      'locationSubtitle': '',
      'shortDescription': shortDescription.isNotEmpty
          ? shortDescription
          : 'No short description available for this event.',
      'description': fullDescription.isNotEmpty
          ? fullDescription
          : (shortDescription.isNotEmpty
                ? shortDescription
                : 'No description available for this event.'),
      'attended': true,
      '_eventDateValue': _dateOnly(parsedDate),
    };
  }

  static DateTime? _eventDateValue(Map<String, dynamic> event) {
    final value = event['_eventDateValue'];
    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return _dateOnly(value);
    }

    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return null;
    }

    return _dateOnly(parsed);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
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

  static Future<String> _resolveCurrentStudentIdOrEmpty() async {
    final profile = await SupabaseProfileRepositoryImpl.instance
        .getCurrentUserProfile();
    final profileStudentId = _readString(profile?.studentId);
    if (profileStudentId.isNotEmpty) {
      return profileStudentId;
    }

    final user = SupabaseAuthService.currentUser;
    final metadataStudentId = _readString(user?.userMetadata?['student_id']);
    if (metadataStudentId.isNotEmpty) {
      return metadataStudentId;
    }

    final email = _readString(user?.email);
    if (email.isEmpty) {
      return '';
    }

    final studentRow = await _client
        .from(_studentsTable)
        .select('student_id')
        .ilike('email', email)
        .maybeSingle();

    return _readString(studentRow?['student_id']);
  }

  static Map<String, dynamic> _withNoStudentAttendance(
    Map<String, dynamic> event,
  ) {
    return {
      ...event,
      'attended': false,
      'studentTimeIn': null,
      'studentTimeOut': null,
    };
  }

  static String _formatDisplayClock(DateTime value) {
    final hour24 = value.hour;
    final minuteText = value.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }

  static String _formatTimeRange(dynamic start, dynamic end) {
    final startText = _formatTime(start);
    final endText = _formatTime(end);

    if (startText.isEmpty && endText.isEmpty) {
      return '-';
    }

    if (startText.isEmpty) {
      return endText;
    }

    if (endText.isEmpty) {
      return startText;
    }

    return '$startText - $endText';
  }

  static String _formatTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return '';
    }

    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match == null) {
      return raw;
    }

    final hour24 = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour24 == null || minute == null) {
      return raw;
    }

    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minuteText = minute.toString().padLeft(2, '0');

    return '$hour12:$minuteText $period';
  }
}

class _StudentAttendanceSnapshot {
  const _StudentAttendanceSnapshot({
    required this.scannedTimeIn,
    required this.scannedTimeOut,
    required this.status,
  });

  final DateTime? scannedTimeIn;
  final DateTime? scannedTimeOut;
  final String status;

  _StudentAttendanceSnapshot merge(_StudentAttendanceSnapshot other) {
    return _StudentAttendanceSnapshot(
      scannedTimeIn: _earliest(scannedTimeIn, other.scannedTimeIn),
      scannedTimeOut: _latest(scannedTimeOut, other.scannedTimeOut),
      status: other.status.isNotEmpty ? other.status : status,
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
