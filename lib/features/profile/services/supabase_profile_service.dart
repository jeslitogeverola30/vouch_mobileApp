import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/services/supabase_auth_service.dart';

class SupabaseProfileService {
  SupabaseProfileService._();

  static final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'students';

  static Future<void> ensureCurrentUserProfile() async {
    final user = SupabaseAuthService.currentUser;
    if (user == null) {
      return;
    }

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? _readString(metadata['email']);
    if (email == null || email.isEmpty) {
      return;
    }

    final fullName = _resolveFullName(metadata) ?? 'Student';
    final studentId = _readString(metadata['student_id']) ?? user.id;
    final faculty = _readString(metadata['faculty']) ?? 'N/A';
    final program = _readString(metadata['program']) ?? 'N/A';

    await _client.from(_table).upsert({
      'student_id': studentId,
      'email': email,
      'full_name': fullName,
      'faculty': faculty,
      'program': program,
      'password_hash': 'supabase_auth_managed',
      'profile_photo_url': '',
      'account_status': 'active',
    }, onConflict: 'email');
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = SupabaseAuthService.currentUser;
    if (user == null) {
      return null;
    }

    await ensureCurrentUserProfile();

    return _client
        .from(_table)
        .select('email, full_name, student_id, faculty, program, created_at')
        .eq('email', user.email ?? '')
        .maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> getAllProfiles() async {
    final response = await _client
        .from(_table)
        .select('email, full_name, student_id, faculty, program, created_at')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> syncCurrentUserEmail({
    required String previousEmail,
  }) async {
    final user = SupabaseAuthService.currentUser;
    final nextEmail = user?.email;

    if (nextEmail == null ||
        nextEmail.isEmpty ||
        previousEmail.isEmpty ||
        previousEmail == nextEmail) {
      return;
    }

    await _client
        .from(_table)
        .update({'email': nextEmail})
        .eq('email', previousEmail);

    await ensureCurrentUserProfile();
  }

  static String? _resolveFullName(Map<String, dynamic> metadata) {
    final explicit = _readString(metadata['full_name']);
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final first = _readString(metadata['first_name']);
    final last = _readString(metadata['last_name']);
    final combined = [
      if (first != null) first,
      if (last != null) last,
    ].join(' ').trim();

    if (combined.isEmpty) {
      return null;
    }

    return combined;
  }

  static String? _readString(dynamic value) {
    if (value is! String) {
      return null;
    }

    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
