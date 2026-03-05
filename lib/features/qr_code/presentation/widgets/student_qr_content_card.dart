import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_meta_item.dart';

class StudentQrContentCard extends StatelessWidget {
  const StudentQrContentCard({
    super.key,
    required this.userAvatarPath,
    this.avatarUrl,
    required this.fullName,
    required this.studentId,
    required this.isLoadingProfile,
    required this.qrData,
    required this.program,
    required this.faculty,
  });

  final String userAvatarPath;
  final String? avatarUrl;
  final String fullName;
  final String studentId;
  final bool isLoadingProfile;
  final String qrData;
  final String program;
  final String faculty;

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lightGray = Color(0xFFF5F5F5);
  static const Color _textGray = Color(0xFF666666);

  Widget _buildAvatarImage() {
    final normalizedAvatarUrl = avatarUrl?.trim() ?? '';

    if (normalizedAvatarUrl.isNotEmpty) {
      return Image.network(
        normalizedAvatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            userAvatarPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: _lightGray,
                child: const Icon(Ionicons.person, size: 30, color: _royalBlue),
              );
            },
          );
        },
      );
    }

    return Image.asset(
      userAvatarPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: _lightGray,
          child: const Icon(Ionicons.person, size: 30, color: _royalBlue),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _royalBlue.withOpacity(0.12)),
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
                    color: _gold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Ionicons.qr_code_outline,
                    color: _royalBlue,
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
                          color: _textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use this code for attendance and verification',
                        style: GoogleFonts.poppins(
                          color: _textGray,
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
                color: _royalBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _royalBlue.withOpacity(0.12)),
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
                    child: ClipOval(child: _buildAvatarImage()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _royalBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Student ID: $studentId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _textGray,
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
                color: _lightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold, width: 1.8),
              ),
              child: Center(
                child: isLoadingProfile
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
                          color: _royalBlue,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: _royalBlue,
                        ),
                        errorStateBuilder: (cxt, err) {
                          return Container(
                            width: 220,
                            height: 220,
                            color: _lightGray,
                            child: const Center(
                              child: Text('Error generating QR'),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            QrMetaItem(
              icon: Ionicons.school_outline,
              label: 'Program',
              value: program,
              royalBlue: _royalBlue,
              white: _white,
              textGray: _textGray,
            ),
            const SizedBox(height: 8),
            QrMetaItem(
              icon: Ionicons.business_outline,
              label: 'Faculty',
              value: faculty,
              royalBlue: _royalBlue,
              white: _white,
              textGray: _textGray,
            ),
          ],
        ),
      ),
    );
  }
}
