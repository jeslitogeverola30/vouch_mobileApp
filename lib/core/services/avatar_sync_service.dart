import 'package:flutter/foundation.dart';

class SyncedAvatar {
  final String? email;
  final String? avatarUrl;

  const SyncedAvatar({this.email, this.avatarUrl});
}

class AvatarSyncService {
  AvatarSyncService._();

  static final ValueNotifier<SyncedAvatar> notifier = ValueNotifier(
    const SyncedAvatar(),
  );

  static void setAvatar({required String? email, required String? avatarUrl}) {
    final normalizedEmail = email?.trim().toLowerCase();
    final normalizedUrl = avatarUrl?.trim();

    notifier.value = SyncedAvatar(
      email: normalizedEmail == null || normalizedEmail.isEmpty
          ? null
          : normalizedEmail,
      avatarUrl: normalizedUrl == null || normalizedUrl.isEmpty
          ? null
          : normalizedUrl,
    );
  }
}
