import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

import '../../../core/utils/global_header_search.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../profile/data/supabase_profile_repository_impl.dart';
import '../../../core/config/app_router.dart';

const Color royalBlue = Color(0xFF003DA5);
const Color gold = Color(0xFFFFC107);
const Color white = Color(0xFFFFFFFF);
const Color lightGray = Color(0xFFF5F5F5);
const Color textGray = Color(0xFF666666);

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
      profile =
          (await SupabaseProfileRepositoryImpl.instance.getCurrentUserProfile())
              ?.toMap();
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
                _buildQrContentCard(),
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

  Widget _buildQrContentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: royalBlue.withOpacity(0.12)),
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
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Ionicons.qr_code_outline,
                    color: royalBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR VERIFICATION',
                        style: GoogleFonts.poppins(
                          color: textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use this code for attendance and verification',
                        style: GoogleFonts.poppins(
                          color: textGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: royalBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: royalBlue.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
                              size: 30,
                              color: royalBlue,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: royalBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Student ID: $_studentId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: textGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gold, width: 1.8),
              ),
              child: Center(
                child: _isLoadingProfile
                    ? const SizedBox(
                        width: 220,
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 220,
                        gapless: true,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: royalBlue,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: royalBlue,
                        ),
                        errorStateBuilder: (cxt, err) {
                          return Container(
                            width: 220,
                            height: 220,
                            color: lightGray,
                            child: const Center(
                              child: Text('Error generating QR'),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            _buildQrMetaItem(
              icon: Ionicons.school_outline,
              label: 'Program',
              value: _program,
            ),
            const SizedBox(height: 8),
            _buildQrMetaItem(
              icon: Ionicons.business_outline,
              label: 'Faculty',
              value: _faculty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: royalBlue.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: royalBlue.withOpacity(0.8), size: 16),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              color: textGray,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: royalBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
