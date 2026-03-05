import 'profile_entity.dart';

abstract class ProfileRepository {
  Future<void> ensureCurrentUserProfile();

  Future<ProfileEntity?> getCurrentUserProfile();

  Future<List<ProfileEntity>> getAllProfiles();

  Future<void> syncCurrentUserEmail({required String previousEmail});

  Future<void> updateAvatar({required String avatarUrl});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
