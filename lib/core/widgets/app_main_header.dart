import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_router.dart';
import '../services/avatar_sync_service.dart';
import '../../features/auth/data/supabase_auth_service.dart';

class AppMainHeader extends StatefulWidget {
  final String avatarPath;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSearchTap;

  const AppMainHeader({
    super.key,
    this.avatarPath = 'assets/images/my_profile.png',
    this.avatarUrl,
    this.onAvatarTap,
    this.onSearchTap,
  });

  @override
  State<AppMainHeader> createState() => _AppMainHeaderState();
}

class _AppMainHeaderState extends State<AppMainHeader> {
  String? _resolvedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _resolvedAvatarUrl = _normalizeAvatarUrl(widget.avatarUrl);

    AvatarSyncService.notifier.addListener(_onSyncedAvatarChanged);

    if (_resolvedAvatarUrl == null) {
      final syncedAvatar = AvatarSyncService.notifier.value;
      final currentEmail = _normalizedCurrentEmail();
      if (syncedAvatar.email != null && syncedAvatar.email == currentEmail) {
        _resolvedAvatarUrl = _normalizeAvatarUrl(syncedAvatar.avatarUrl);
      }
    }

    if (_resolvedAvatarUrl == null) {
      _loadAvatarFromSupabase();
    }
  }

  @override
  void didUpdateWidget(covariant AppMainHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    final incomingAvatarUrl = _normalizeAvatarUrl(widget.avatarUrl);
    final oldIncomingAvatarUrl = _normalizeAvatarUrl(oldWidget.avatarUrl);

    if (incomingAvatarUrl != oldIncomingAvatarUrl) {
      _resolvedAvatarUrl = incomingAvatarUrl;

      if (incomingAvatarUrl != null) {
        AvatarSyncService.setAvatar(
          email: SupabaseAuthService.currentUser?.email,
          avatarUrl: incomingAvatarUrl,
        );
      }

      if (mounted) {
        setState(() {});
      }

      if (incomingAvatarUrl == null) {
        _loadAvatarFromSupabase();
      }
    }
  }

  @override
  void dispose() {
    AvatarSyncService.notifier.removeListener(_onSyncedAvatarChanged);
    super.dispose();
  }

  void _onSyncedAvatarChanged() {
    final syncedAvatar = AvatarSyncService.notifier.value;
    final currentEmail = _normalizedCurrentEmail();

    if (syncedAvatar.email == null || syncedAvatar.email != currentEmail) {
      return;
    }

    final syncedUrl = _normalizeAvatarUrl(syncedAvatar.avatarUrl);
    if (syncedUrl == _resolvedAvatarUrl) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _resolvedAvatarUrl = syncedUrl;
    });
  }

  Future<void> _loadAvatarFromSupabase() async {
    final email = _normalizedCurrentEmail();
    if (email == null || email.isEmpty) {
      return;
    }

    final client = Supabase.instance.client;

    String? avatarUrl;

    final studentRow = await client
        .from('students')
        .select('profile_photo_url')
        .eq('email', email)
        .maybeSingle();

    final studentUrl = _extractAvatarUrl(studentRow);
    if (studentUrl != null) {
      avatarUrl = studentUrl;
    } else {
      final adminRow = await client
          .from('admins')
          .select('profile_photo_url')
          .ilike('email', email)
          .maybeSingle();
      avatarUrl = _extractAvatarUrl(adminRow);
    }

    if (!mounted || avatarUrl == null) {
      return;
    }

    setState(() {
      _resolvedAvatarUrl = avatarUrl;
    });

    AvatarSyncService.setAvatar(email: email, avatarUrl: avatarUrl);
  }

  String? _extractAvatarUrl(Map<String, dynamic>? row) {
    final value = row?['profile_photo_url'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  String? _normalizeAvatarUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return value.trim();
  }

  String? _normalizedCurrentEmail() {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return null;
    }

    return email.toLowerCase();
  }

  Widget _buildAvatarImage() {
    if (_resolvedAvatarUrl != null) {
      return Image.network(
        _resolvedAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(widget.avatarPath, fit: BoxFit.cover);
        },
      );
    }

    return Image.asset(
      widget.avatarPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: const Color(0xFFE8F0F8));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logos/vouch_logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 2),
              Transform.translate(
                offset: const Offset(-2, 0),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: 'ou',
                        style: TextStyle(color: Color(0xFF003DA5)),
                      ),
                      TextSpan(
                        text: 'ch',
                        style: TextStyle(color: Color(0xFFFFC107)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Ionicons.search, color: Color(0xFF003DA5)),
                onPressed: () {
                  if (widget.onSearchTap != null) {
                    widget.onSearchTap!();
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Ionicons.notifications,
                  color: Color(0xFF003DA5),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (widget.onAvatarTap != null) {
                    widget.onAvatarTap!();
                    return;
                  }
                  Navigator.pushReplacementNamed(context, AppRouter.profile);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF003DA5).withOpacity(0.12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _buildAvatarImage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
