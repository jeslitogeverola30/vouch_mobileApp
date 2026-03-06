import '../../profile/data/supabase_profile_repository_impl.dart';

class AuthProfileSyncService {
  AuthProfileSyncService._();

  static Future<void> ensureCurrentUserProfile() {
    return SupabaseProfileRepositoryImpl.instance.ensureCurrentUserProfile();
  }

  static Future<void> syncCurrentUserEmail({required String previousEmail}) {
    return SupabaseProfileRepositoryImpl.instance.syncCurrentUserEmail(
      previousEmail: previousEmail,
    );
  }
}
