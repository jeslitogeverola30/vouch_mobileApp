import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../domain/event_date_time_formatters.dart';

class EventAdminService {
  EventAdminService._();

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

    await Supabase.instance.client.from('events').insert({
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
}
