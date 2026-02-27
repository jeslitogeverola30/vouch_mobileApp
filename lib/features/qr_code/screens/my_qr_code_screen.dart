import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../profile/services/supabase_profile_service.dart';
import '../../../routes/app_router.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color white = Color(0xFFFFFFFF);
const Color lightGray = Color(0xFFF5F5F5);
const Color textGray = Color(0xFF666666);

class QRScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userDegree;
  final String userEmail;
  final String userAvatarPath;

  const QRScreen({
    Key? key,
    this.userId = 'USER123',
    this.userName = 'Jeslito G. Geverola',
    this.userDegree = 'Bachelor of Science in Information Technology',
    this.userEmail = 'jeslito.geverola@dorsu.ed',
    this.userAvatarPath = 'assets/images/my_profile.png',
  }) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
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
    Map<String, dynamic>? profile;

    try {
      profile = await SupabaseProfileService.getCurrentUserProfile();
    } catch (_) {
      profile = null;
    }

    if (!mounted) {
      return;
    }

    if (profile == null) {
      setState(() {
        _isLoadingProfile = false;
      });
      return;
    }

    final studentId = (profile['student_id'] as String?)?.trim();
    final fullName = (profile['full_name'] as String?)?.trim();
    final faculty = (profile['faculty'] as String?)?.trim();
    final program = (profile['program'] as String?)?.trim();

    setState(() {
      _studentId = (studentId != null && studentId.isNotEmpty)
          ? studentId
          : _studentId;
      _fullName = (fullName != null && fullName.isNotEmpty)
          ? fullName
          : _fullName;
      _faculty = (faculty != null && faculty.isNotEmpty) ? faculty : _faculty;
      _program = (program != null && program.isNotEmpty) ? program : _program;
      qrData = _generateQRData(
        studentId: _studentId,
        fullName: _fullName,
        faculty: _faculty,
        program: _program,
      );
      _isLoadingProfile = false;
    });
  }

  String _generateQRData({
    required String studentId,
    required String fullName,
    required String faculty,
    required String program,
  }) {
    return jsonEncode({
      'student_id': studentId,
      'full_name': fullName,
      'faculty': faculty,
      'program': program,
    });
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
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIntroCard(),
                          const SizedBox(height: 20),
                          _buildQrContentCard(),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _downloadQRCode,
                                icon: const Icon(
                                  Ionicons.download_outline,
                                  size: 20,
                                ),
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
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            if (index == _selectedNavIndex) {
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

            if (index == 4) {
              Navigator.pushReplacementNamed(context, AppRouter.profile);
              return;
            }

            setState(() {
              _selectedNavIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Ionicons.notifications,
                  color: Color(0xFF003DA5),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(widget.userAvatarPath),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: royalBlue.withOpacity(0.1)),
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
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(),
                children: const [
                  TextSpan(
                    text: 'My ',
                    style: TextStyle(
                      color: royalBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'QR ',
                    style: TextStyle(
                      color: gold,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'Code',
                    style: TextStyle(
                      color: gold,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Present this code for attendance and student verification.',
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: royalBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Student ID: $_studentId',
                style: GoogleFonts.poppins(
                  color: royalBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: royalBlue.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  widget.userAvatarPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: lightGray,
                      child: const Icon(
                        Ionicons.person,
                        size: 42,
                        color: royalBlue,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _fullName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: royalBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _program,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold, width: 2),
              ),
              child: _isLoadingProfile
                  ? const SizedBox(
                      width: 210,
                      height: 210,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 210,
                      gapless: true,
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          width: 210,
                          height: 210,
                          color: lightGray,
                          child: const Center(
                            child: Text('Error generating QR'),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              'Faculty: $_faculty',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
