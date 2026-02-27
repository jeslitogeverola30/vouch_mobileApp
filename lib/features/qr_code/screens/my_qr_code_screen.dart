import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/widgets/app_bottom_navigation_bar.dart';
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
  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    // Generate unique QR data from user information
    qrData = _generateQRData();
  }

  String _generateQRData() {
    // Create a unique string from user data
    // In production, this could be a JSON payload or a unique token
    return '${widget.userId}|${widget.userEmail}|${DateTime.now().millisecondsSinceEpoch}';
  }

  void _downloadQRCode() {
    // Show snackbar for demonstration
    // In production, implement actual download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code download initiated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          // Decorative background shapes
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: royalBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: 20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: royalBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header with status bar spacing
                Padding(
                  padding: EdgeInsets.only(
                    top: isSmallScreen ? 16 : 24,
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logos/vouch_logo.png',
                        height: isSmallScreen ? 48 : 56,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      // Title
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'My ',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 32,
                                fontWeight: FontWeight.bold,
                                color: royalBlue,
                              ),
                            ),
                            TextSpan(
                              text: 'QR ',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 32,
                                fontWeight: FontWeight.bold,
                                color: gold,
                              ),
                            ),
                            TextSpan(
                              text: 'Code',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 32,
                                fontWeight: FontWeight.bold,
                                color: gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // User profile section
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: royalBlue, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: royalBlue.withOpacity(0.2),
                              blurRadius: 12,
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
                                child: const Center(
                                  child: Icon(
                                    Ionicons.person,
                                    size: 50,
                                    color: royalBlue,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User name
                      Text(
                        widget.userName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // User degree
                      Text(
                        widget.userDegree,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // QR Code Container
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 32,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: royalBlue.withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // QR Code
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: gold, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: isSmallScreen ? 200 : 240,
                            gapless: true,
                            errorStateBuilder: (cxt, err) {
                              return Container(
                                color: lightGray,
                                child: const Center(
                                  child: Text('Error generating QR'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Download button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 32,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _downloadQRCode,
                      icon: const Icon(Ionicons.download, size: 20),
                      label: const Text(
                        'Download QR Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: royalBlue,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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

          if (index == 4) {
            Navigator.pushReplacementNamed(context, AppRouter.profile);
            return;
          }

          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }
}
