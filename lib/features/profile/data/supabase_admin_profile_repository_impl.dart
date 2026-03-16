import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../domain/profile_entity.dart';

class SupabaseAdminProfileRepositoryImpl {
  SupabaseAdminProfileRepositoryImpl._();

  static final SupabaseAdminProfileRepositoryImpl instance =
      SupabaseAdminProfileRepositoryImpl._();

  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'admins';

  Future<String?> getCurrentAvatarUrl() async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return null;
    }

    final response = await _client
        .from(_table)
        .select('profile_photo_url')
        .ilike('email', email)
        .maybeSingle();

    final url = response?['profile_photo_url'];
    if (url is String && url.trim().isNotEmpty) {
      return url.trim();
    }

    return null;
  }

  Future<ProfileEntity?> getCurrentUserProfile() async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return null;
    }

    final response = await _client
        .from(_table)
        .select('full_name, email, faculty, profile_photo_url')
        .ilike('email', email)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfileEntity(
      fullName: response['full_name'] as String? ?? '',
      email: response['email'] as String? ?? '',
      studentId: '', // Not applicable for admin
      faculty: response['faculty'] as String? ?? '',
      program: '', // Not applicable for admin
      profilePhotoUrl: response['profile_photo_url'] as String? ?? '',
    );
  }

  Future<void> updateAvatar({required String avatarUrl}) async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      throw StateError('No signed-in admin found.');
    }

    await _client
        .from(_table)
        .update({'profile_photo_url': avatarUrl.trim()})
        .ilike('email', email);
  }
}
