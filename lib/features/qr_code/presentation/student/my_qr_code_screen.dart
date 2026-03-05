import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/utils/global_header_search.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_main_header.dart';
import '../../../../core/config/app_router.dart';
import '../../data/qr_student_profile_repository_impl.dart';
import '../../domain/qr_student_profile_entity.dart';
import '../../domain/qr_utils.dart';
import '../widgets/student_qr_content_card.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color white = Color(0xFFFFFFFF);

class QRScreen extends StatefulWidget {
  final bool showChrome;
  final String userId;
  final String userName;
  final String userDegree;
  final String userEmail;
  final String userAvatarPath;

  const QRScreen({
    super.key,
    this.showChrome = true,
    this.userId = 'USER123',
    this.userName = 'Jeslito G. Geverola',
    this.userDegree = 'Bachelor of Science in Information Technology',
    this.userEmail = 'jeslito.geverola@dorsu.ed',
    this.userAvatarPath = 'assets/images/my_profile.png',
  });

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final QrStudentProfileRepositoryImpl _profileRepository =
      QrStudentProfileRepositoryImpl.instance;
  late String qrData;
  late String _studentId;
  late String _fullName;
  late String _faculty;
  late String _program;
  bool _isLoadingProfile = true;
  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _studentId = widget.userId;
    _fullName = widget.userName;
    _faculty = 'N/A';
    _program = widget.userDegree;
    qrData = _generateQRData(
      studentId: _studentId,
      fullName: _fullName,
      faculty: _faculty,
      program: _program,
    );
    _loadProfileFromDatabase();
  }

  Future<void> _loadProfileFromDatabase() async {
    final profile = await _safeGetCurrentProfile();

    if (!mounted) {
      return;
    }

    if (profile == null) {
      setState(() {
        _isLoadingProfile = false;
      });
      return;
    }

    setState(() {
      _studentId = profile.studentId.isNotEmpty
          ? profile.studentId
          : _studentId;
      _fullName = profile.fullName.isNotEmpty ? profile.fullName : _fullName;
      _faculty = profile.faculty.isNotEmpty ? profile.faculty : _faculty;
      _program = profile.program.isNotEmpty ? profile.program : _program;
      qrData = _generateQRData(
        studentId: _studentId,
        fullName: _fullName,
        faculty: _faculty,
        program: _program,
      );
      _isLoadingProfile = false;
    });
  }

  Future<QrStudentProfileEntity?> _safeGetCurrentProfile() async {
    try {
      return await _profileRepository.getCurrentStudentProfile();
    } catch (_) {
      return null;
    }
  }

  String _generateQRData({
    required String studentId,
    required String fullName,
    required String faculty,
    required String program,
  }) {
    return QrUtils.generateStudentQrPayload(
      studentId: studentId,
      fullName: fullName,
      faculty: faculty,
      program: program,
    );
  }

  void _downloadQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code download initiated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: white,
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
                currentIndex: _selectedNavIndex,
                onTap: (index) {
                  if (index == _selectedNavIndex) {
                    return;
                  }

                  if (index == 0) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.studentHome,
                    );
                    return;
                  }

                  if (index == 1) {
                    Navigator.pushReplacementNamed(context, AppRouter.events);
                    return;
                  }

                  if (index == 3) {
                    Navigator.pushReplacementNamed(context, AppRouter.payments);
                    return;
                  }

                  if (index == 4) {
                    Navigator.pushReplacementNamed(context, AppRouter.profile);
                    return;
                  }

                  setState(() {
                    _selectedNavIndex = index;
                  });
                },
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
            avatarPath: widget.userAvatarPath,
            onSearchTap: () => openGlobalHeaderSearch(context),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudentQrContentCard(
                  userAvatarPath: widget.userAvatarPath,
                  fullName: _fullName,
                  studentId: _studentId,
                  isLoadingProfile: _isLoadingProfile,
                  qrData: qrData,
                  program: _program,
                  faculty: _faculty,
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _downloadQRCode,
                      icon: const Icon(Ionicons.download_outline, size: 20),
                      label: Text(
                        'Download QR Code',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: royalBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
