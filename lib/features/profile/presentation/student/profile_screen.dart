import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/data/local/database_helper.dart';
import '../../../../core/services/avatar_sync_service.dart';
import '../../../../core/utils/global_header_search.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_main_header.dart';
import '../../../../core/config/app_router.dart';
import '../../../auth/data/supabase_auth_service.dart';
import '../../../student_management/data/academic_term_service.dart';
import '../../data/profile_image_upload_service.dart';
import '../../data/supabase_profile_repository_impl.dart';

class ProfileScreen extends StatefulWidget {
  final bool showChrome;
  final String userName;
  final String userRole;
  final String userEmail;
  final String studentId;
  final String faculty;
  final String program;
  final String bannerPath;
  final String avatarPath;

  const ProfileScreen({
    super.key,
    this.showChrome = true,
    this.userName = 'Jeslito G. Geverola',
    this.userRole = 'DOrSU Student',
    this.userEmail = 'jeslito.geverola@dorsu.edu.ph',
    this.studentId = '2023-0222',
    this.faculty = 'Faculty of Computing, Engineering,\nand Technology',
    this.program = 'BS - Information Technology',
    this.bannerPath = 'assets/logos/vouch_banner.png',
    this.avatarPath = 'assets/images/my_profile.png',
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  int _selectedIndex = 4;
  bool _isLoggingOut = false;
  bool _isUploadingAvatar = false;
  bool _isLoadingAcademicTerm = true;

  late String _userName;
  late String _userEmail;
  late String _studentId;
  late String _faculty;
  late String _program;
  String _avatarUrl = '';
  AcademicTermOption? _activeAcademicTerm;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _studentId = widget.studentId;
    _faculty = widget.faculty;
    _program = widget.program;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      _loadAcademicTerm();
    });
  }

  Future<void> _loadProfile() async {
    final email = SupabaseAuthService.currentUser?.email ?? widget.userEmail;

    Map<String, dynamic>? student;
    try {
      student =
          (await SupabaseProfileRepositoryImpl.instance.getCurrentUserProfile())
              ?.toMap();
    } catch (_) {
      student = null;
    }

    student ??= await DatabaseHelper.instance.getStudentByEmail(email);

    if (student == null || !mounted) {
      return;
    }

    setState(() {
      _userName = (student!['full_name'] as String? ?? widget.userName);
      _userEmail = (student['email'] as String? ?? email);
      _studentId = (student['student_id'] as String? ?? widget.studentId);
      _faculty = (student['faculty'] as String? ?? widget.faculty);
      _program = (student['program'] as String? ?? widget.program);
      _avatarUrl = (student['profile_photo_url'] as String? ?? '').trim();
    });

    AvatarSyncService.setAvatar(email: _userEmail, avatarUrl: _avatarUrl);
  }

  Future<void> _loadAcademicTerm() async {
    List<AcademicTermOption> terms = const <AcademicTermOption>[];

    try {
      terms = await AcademicTermService.fetchTerms();
    } catch (_) {
      terms = const <AcademicTermOption>[];
    }

    AcademicTermOption? activeTerm;
    for (final term in terms) {
      if (term.isActive) {
        activeTerm = term;
        break;
      }
    }

    activeTerm ??= terms.isNotEmpty ? terms.first : null;

    if (!mounted) {
      return;
    }

    setState(() {
      _activeAcademicTerm = activeTerm;
      _isLoadingAcademicTerm = false;
    });
  }

  String get _academicTermLabel {
    if (_isLoadingAcademicTerm) {
      return 'Loading...';
    }

    return _activeAcademicTerm?.label ?? 'No active term set';
  }

  Future<void> _showAvatarActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Profile Picture',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Ionicons.eye_outline,
                    color: Color(0xFF003DA5),
                  ),
                  title: const Text('View profile picture'),
                  onTap: () => Navigator.of(context).pop('view'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Ionicons.image_outline,
                    color: Color(0xFF003DA5),
                  ),
                  title: const Text('Change profile picture'),
                  onTap: () => Navigator.of(context).pop('change'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == 'view') {
      _showAvatarPreview();
      return;
    }

    if (action == 'change') {
      await _pickAndUploadAvatar();
    }
  }

  void _showAvatarPreview() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile Picture',
                    style: TextStyle(
                      color: Color(0xFF003DA5),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: _buildAvatarImage(),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) {
      return;
    }

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
      maxHeight: 2000,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() => _isUploadingAvatar = true);

    try {
      final imageUrl = await ProfileImageUploadService.uploadProfileImage(
        imageFile: File(picked.path),
      );

      await SupabaseProfileRepositoryImpl.instance.updateAvatar(
        avatarUrl: imageUrl,
      );

      if (!mounted) {
        return;
      }

      setState(() => _avatarUrl = imageUrl);

      AvatarSyncService.setAvatar(email: _userEmail, avatarUrl: imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final raw = error.toString();
      final message = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '').trim()
          : 'Failed to update profile picture. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Widget _buildAvatarImage() {
    if (_avatarUrl.isNotEmpty) {
      return Image.network(
        _avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFE8F0F8),
            child: const Icon(
              Ionicons.person,
              size: 22,
              color: Color(0xFF003DA5),
            ),
          );
        },
      );
    }

    return Image.asset(
      widget.avatarPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE8F0F8),
          child: const Icon(
            Ionicons.person,
            size: 22,
            color: Color(0xFF003DA5),
          ),
        );
      },
    );
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRouter.studentHome);
      return;
    }

    if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRouter.events);
      return;
    }

    if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRouter.myQrCode);
      return;
    }

    if (index == 3) {
      Navigator.pushReplacementNamed(context, AppRouter.payments);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF003DA5),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to logout from this device?',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF003DA5),
                        side: BorderSide(
                          color: const Color(0xFF003DA5).withOpacity(0.25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3261E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout != true || _isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await SupabaseAuthService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 260,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF003DA5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            widget.showChrome
                ? SafeArea(child: _buildMainContent())
                : _buildMainContent(),
          ],
        ),
        bottomNavigationBar: widget.showChrome
            ? AppBottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onNavItemTapped,
              )
            : null,
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChrome)
          AppMainHeader(
            avatarPath: widget.avatarPath,
            avatarUrl: _avatarUrl,
            onSearchTap: () => openGlobalHeaderSearch(context),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildProfileSummaryCard(),
                ),
                const SizedBox(height: 22),
                _buildSectionHeader(
                  title: 'Academic Details',
                  subtitle: 'Your student profile information',
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Ionicons.card_outline,
                        label: 'Student ID',
                        value: _studentId,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Ionicons.calendar_outline,
                        label: 'Academic Term',
                        value: _academicTermLabel,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Ionicons.people,
                        label: 'Faculty',
                        value: _faculty,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Ionicons.school_outline,
                        label: 'Program',
                        value: _program,
                      ),
                      const SizedBox(height: 12),
                      _buildAccountActionButton(
                        icon: Ionicons.document_outline,
                        title: 'View Activity Card',
                        subtitle: 'See your student activity details',
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.activityCard);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _buildSectionHeader(
                  title: 'Account',
                  subtitle: 'Manage your login and security settings',
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildAccountActionButton(
                        icon: Ionicons.mail_outline,
                        title: 'Change Email',
                        subtitle: 'Update your account email address',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.sensitiveReauth,
                            arguments: AppRouter.changeEmail,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAccountActionButton(
                        icon: Ionicons.lock_closed_outline,
                        title: 'Change Password',
                        subtitle: 'Secure your account with a new password',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.sensitiveReauth,
                            arguments: AppRouter.changePassword,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAccountActionButton(
                        icon: Ionicons.log_out_outline,
                        title: 'Logout',
                        subtitle: 'Sign out from this device',
                        onTap: _handleLogout,
                        isDestructive: true,
                      ),
                      const SizedBox(height: 34),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _showAvatarActions,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _buildAvatarImage(),
                      ),
                      if (_isUploadingAvatar)
                        Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _userName,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _userEmail,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.userRole,
              style: const TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF003DA5),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF003DA5), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isLogoutLoading = isDestructive && _isLoggingOut;
    final iconColor = isDestructive
        ? const Color(0xFFB3261E)
        : const Color(0xFF003DA5);
    final iconBgColor = isDestructive
        ? const Color(0xFFFDECEA)
        : const Color(0xFF003DA5).withOpacity(0.1);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isLogoutLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFB3261E).withOpacity(0.22)
                  : const Color(0xFF003DA5).withOpacity(0.12),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDestructive
                            ? const Color(0xFF8B4A47)
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                color: isDestructive
                    ? const Color(0xFFB3261E).withOpacity(0.45)
                    : const Color(0xFF9CA3AF),
                size: 18,
              ),
              const SizedBox(width: 6),
              if (isLogoutLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFB3261E),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
