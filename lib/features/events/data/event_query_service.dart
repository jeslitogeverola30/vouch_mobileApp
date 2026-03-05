import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/event_date_time_formatters.dart';

class EventQueryService {
  EventQueryService._();

  static Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await Supabase.instance.client
        .from('events')
        .select(
          'id, name, short_description, full_description, location, image_url, event_date, schedule_time_in_start, schedule_time_in_end, schedule_time_out_start, schedule_time_out_end, is_mandatory',
        )
        .order('event_date', ascending: true);

    final rows = List<Map<String, dynamic>>.from(response);

    return rows.map(_mapEventRow).toList();
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
      'image': imageUrl.isEmpty ? 'assets/images/event-siglakas.jpg' : imageUrl,
      'isObligatory': row['is_mandatory'] == true,
      'location': _readString(row['location']).isEmpty
          ? 'University Campus'
          : _readString(row['location']),
      'locationSubtitle': 'Davao Oriental State University',
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

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
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
