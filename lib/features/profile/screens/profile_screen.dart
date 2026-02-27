import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/data/local/database_helper.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../routes/app_router.dart';
import '../../auth/services/supabase_auth_service.dart';
import '../services/supabase_profile_service.dart';

class ProfileScreen extends StatefulWidget {
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
  int _selectedIndex = 4; // Profile tab is selected
  late String _userName;
  late String _userEmail;
  late String _studentId;
  late String _faculty;
  late String _program;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _studentId = widget.studentId;
    _faculty = widget.faculty;
    _program = widget.program;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileFromLocalDb();
    });
  }

  Future<void> _loadProfileFromLocalDb() async {
    final email = SupabaseAuthService.currentUser?.email ?? widget.userEmail;

    Map<String, dynamic>? student;

    try {
      student = await SupabaseProfileService.getCurrentUserProfile();
    } catch (_) {
      student = null;
    }

    student ??= await DatabaseHelper.instance.getStudentByEmail(email);

    if (student == null || !mounted) {
      return;
    }

    final currentStudent = student;

    setState(() {
      _userName = (currentStudent['full_name'] as String? ?? widget.userName);
      _userEmail = (currentStudent['email'] as String? ?? email);
      _studentId =
          (currentStudent['student_id'] as String? ?? widget.studentId);
      _faculty = (currentStudent['faculty'] as String? ?? widget.faculty);
      _program = (currentStudent['program'] as String? ?? widget.program);
    });
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

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await SupabaseAuthService.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.25,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.2,
                            child: Image.asset(
                              widget.bannerPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF003DA5),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -36,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(54),
                                child: Image.asset(
                                  widget.avatarPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFE8F0F8),
                                      child: const Center(
                                        child: Icon(
                                          Ionicons.person,
                                          size: 50,
                                          color: Color(0xFF003DA5),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 52),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Navigating to Activity Card'),
                                duration: Duration(seconds: 1),
                              ),
                            );
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
                            Navigator.pushNamed(context, AppRouter.changeEmail);
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
                              AppRouter.changePassword,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildAccountActionButton(
                          icon: Ionicons.server_outline,
                          title: 'View Local Students DB',
                          subtitle: 'See saved student records on this device',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.studentsDatabase,
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
            Positioned(
              bottom: 200,
              right: -30,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003DA5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(150),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
        ),
      ),
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
          Text(
            _userName,
            style: const TextStyle(
              color: Color(0xFF003DA5),
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF003DA5), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003DA5),
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
    final iconColor = isDestructive
        ? const Color(0xFFB3261E)
        : const Color(0xFF003DA5);
    final iconBgColor = isDestructive
        ? const Color(0xFFFDECEA)
        : const Color(0xFFE8F0F8);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive
                  ? const Color(0xFFB3261E).withOpacity(0.25)
                  : const Color(0xFF003DA5).withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Ionicons.chevron_forward,
                color: iconColor.withOpacity(0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
