import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../domain/event_date_time_formatters.dart';

class EventAdminService {
  EventAdminService._();

  static const String _academicTermsTable = 'academic_terms';

  static Future<void> createEvent({
    required String name,
    required String shortDescription,
    required String fullDescription,
    required String location,
    required String imageUrl,
    required DateTime eventDate,
    required int timeInStartMinutes,
    required int timeInEndMinutes,
    required int timeOutStartMinutes,
    required int timeOutEndMinutes,
    required bool isMandatory,
  }) async {
    final adminId = await _resolveCurrentAdminId();
    final termId = await _resolveActiveTermId();

    await Supabase.instance.client.from('events').insert({
      'term_id': termId,
      'name': name,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'location': location,
      'image_url': imageUrl.trim(),
      'event_date': EventDateTimeFormatters.databaseDate(eventDate),
      'schedule_time_in_start': EventDateTimeFormatters.databaseTimeFromMinutes(
        timeInStartMinutes,
      ),
      'schedule_time_in_end': EventDateTimeFormatters.databaseTimeFromMinutes(
        timeInEndMinutes,
      ),
      'schedule_time_out_start':
          EventDateTimeFormatters.databaseTimeFromMinutes(timeOutStartMinutes),
      'schedule_time_out_end': EventDateTimeFormatters.databaseTimeFromMinutes(
        timeOutEndMinutes,
      ),
      'is_mandatory': isMandatory,
      'admin_id': adminId,
    });
  }

  static Future<void> updateEvent({
    required int eventId,
    required String name,
    required String shortDescription,
    required String fullDescription,
    required String location,
    required String imageUrl,
    required DateTime eventDate,
    required int timeInStartMinutes,
    required int timeInEndMinutes,
    required int timeOutStartMinutes,
    required int timeOutEndMinutes,
    required bool isMandatory,
  }) async {
    await Supabase.instance.client
        .from('events')
        .update({
          'name': name,
          'short_description': shortDescription,
          'full_description': fullDescription,
          'location': location,
          'image_url': imageUrl.trim(),
          'event_date': EventDateTimeFormatters.databaseDate(eventDate),
          'schedule_time_in_start':
              EventDateTimeFormatters.databaseTimeFromMinutes(
                timeInStartMinutes,
              ),
          'schedule_time_in_end':
              EventDateTimeFormatters.databaseTimeFromMinutes(timeInEndMinutes),
          'schedule_time_out_start':
              EventDateTimeFormatters.databaseTimeFromMinutes(
                timeOutStartMinutes,
              ),
          'schedule_time_out_end':
              EventDateTimeFormatters.databaseTimeFromMinutes(
                timeOutEndMinutes,
              ),
          'is_mandatory': isMandatory,
        })
        .eq('id', eventId);
  }

  static Future<void> deleteEvent({required int eventId}) async {
    await Supabase.instance.client.from('events').delete().eq('id', eventId);
  }

  static Future<int> _resolveCurrentAdminId() async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      throw Exception('No authenticated admin found');
    }

    final admin = await Supabase.instance.client
        .from('admins')
        .select('id')
        .ilike('email', email)
        .maybeSingle();

    final adminId = admin?['id'];
    if (adminId is int) {
      return adminId;
    }

    if (adminId is String) {
      final parsed = int.tryParse(adminId);
      if (parsed != null) {
        return parsed;
      }
    }

    throw Exception('Admin account not found');
  }

  static Future<int> _resolveActiveTermId() async {
    final activeTerm = await Supabase.instance.client
        .from(_academicTermsTable)
        .select('id')
        .eq('is_active', true)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    final activeTermId = _readInt(activeTerm?['id']);
    if (activeTermId > 0) {
      return activeTermId;
    }

    final fallbackTerm = await Supabase.instance.client
        .from(_academicTermsTable)
        .select('id')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    final fallbackTermId = _readInt(fallbackTerm?['id']);
    if (fallbackTermId > 0) {
      return fallbackTermId;
    }

    throw Exception(
      'No academic term found. Please add an academic term first',
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }
}
