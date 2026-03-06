import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../domain/profile_entity.dart';
import '../domain/profile_repository.dart';

class SupabaseProfileRepositoryImpl implements ProfileRepository {
  SupabaseProfileRepositoryImpl._();

  static final SupabaseProfileRepositoryImpl instance =
      SupabaseProfileRepositoryImpl._();

  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'students';

  @override
  Future<void> ensureCurrentUserProfile() async {
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

    final existingRow = await _client
        .from(_table)
        .select('profile_photo_url, account_status, password_hash')
        .eq('email', email)
        .maybeSingle();

    final existingProfilePhotoUrl = _readString(
      existingRow?['profile_photo_url'],
    );
    final existingAccountStatus =
        _readString(existingRow?['account_status']) ?? 'active';
    final existingPasswordHash =
        _readString(existingRow?['password_hash']) ?? 'supabase_auth_managed';

    await _client.from(_table).upsert({
      'student_id': studentId,
      'email': email,
      'full_name': fullName,
      'faculty': faculty,
      'program': program,
      'password_hash': existingPasswordHash,
      'profile_photo_url': existingProfilePhotoUrl ?? '',
      'account_status': existingAccountStatus,
    }, onConflict: 'email');
  }

  @override
  Future<ProfileEntity?> getCurrentUserProfile() async {
    final user = SupabaseAuthService.currentUser;
    if (user == null) {
      return null;
    }

    await ensureCurrentUserProfile();

    final response = await _client
        .from(_table)
        .select(
          'email, full_name, student_id, faculty, program, created_at, profile_photo_url, account_status',
        )
        .eq('email', user.email ?? '')
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfileEntity.fromMap(Map<String, dynamic>.from(response));
  }

  @override
  Future<List<ProfileEntity>> getAllProfiles() async {
    final response = await _client
        .from(_table)
        .select(
          'email, full_name, student_id, faculty, program, created_at, profile_photo_url, account_status',
        )
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(ProfileEntity.fromMap).toList();
  }

  @override
  Future<void> syncCurrentUserEmail({required String previousEmail}) async {
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

  @override
  Future<void> updateAvatar({required String avatarUrl}) async {
    final email = SupabaseAuthService.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }

    await _client
        .from(_table)
        .update({'profile_photo_url': avatarUrl.trim()})
        .eq('email', email);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = SupabaseAuthService.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw StateError('No signed-in user found.');
    }

    await SupabaseAuthService.signInWithPassword(
      email: email,
      password: currentPassword,
    );

    await SupabaseAuthService.updatePassword(newPassword: newPassword);
  }

  String? _resolveFullName(Map<String, dynamic> metadata) {
    final explicit = _readString(metadata['full_name']);
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }

    final first = _readString(metadata['first_name']);
    final last = _readString(metadata['last_name']);
    final combined = [?first, ?last].join(' ').trim();

    if (combined.isEmpty) {
      return null;
    }

    return combined;
  }

  String? _readString(dynamic value) {
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
