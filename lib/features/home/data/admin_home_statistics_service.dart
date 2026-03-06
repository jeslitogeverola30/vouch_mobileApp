import 'package:supabase_flutter/supabase_flutter.dart';

class AdminHomeStatisticsService {
  AdminHomeStatisticsService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static const String _studentsTable = 'students';
  static const String _eventsTable = 'events';

  static Future<int> fetchTotalStudentsCount() async {
    final response = await _client.from(_studentsTable).select('student_id');
    return List<Map<String, dynamic>>.from(response).length;
  }

  static Future<int> fetchUpcomingEventsCount() async {
    final todayDate = _databaseDate(DateTime.now());

    final response = await _client
        .from(_eventsTable)
        .select('id')
        .gt('event_date', todayDate);

    return List<Map<String, dynamic>>.from(response).length;
  }

  static String _databaseDate(DateTime value) {
    final dateOnly = DateTime(value.year, value.month, value.day);
    final year = dateOnly.year.toString().padLeft(4, '0');
    final month = dateOnly.month.toString().padLeft(2, '0');
    final day = dateOnly.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
