import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import '../../core/theme/app_dimensions.dart';

/// Vouch Profile Screen (About Vouch)
/// Re-designed to match the UI/UX of the Proof of Payment screen
class VouchProfileScreen extends StatelessWidget {
  const VouchProfileScreen({super.key});

  // Project colors
  static const Color royalBlue = Color(0xFF003DA5);
  static const Color gold = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Decorative background circles from Proof of Payment UI
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildLogoSection(),

                            const SizedBox(height: 16),
                            _buildCardSection(
                              title: 'Vision',
                              content:
                                  'To become a reliable digital platform that modernizes student clearance, attendance, and compliance processes in educational institutions through efficient, secure, and accessible technology.',
                            ),
                            const SizedBox(height: 24),
                            _buildCardSection(
                              title: 'Mission',
                              content:
                                  '• Provide a centralized system for managing student attendance, payments, and academic clearance\n'
                                  '• Reduce reliance on paper-based processes through digital innovation\n'
                                  '• Ensure accurate, real-time tracking of student obligations\n'
                                  '• Support administrators with efficient tools for monitoring and verification\n'
                                  '• Continuously improve the system based on user feedback and institutional needs',
                            ),
                            const SizedBox(height: 16),
                            _buildCardSection(
                              title: 'History',
                              content:
                                  'Vouch was developed as a prototype by a third-year BSIT student as part of an initiative to address common challenges in managing student activity cards, attendance, and payment verification. '
                                  'The idea originated from the need to replace manual, paper-based systems with a more efficient digital solution that ensures accuracy, transparency, and convenience for both students and administrators. '
                                  'Currently, Vouch is being introduced for evaluation and feedback, with the goal of refining the system and exploring its potential implementation in academic institutions.',
                            ),
                            const SizedBox(height: 24),
                            _buildSectionLabel('Developer'),
                            const SizedBox(height: 12),
                            _buildDeveloperCard(),
                            const SizedBox(height: 24),
                            _buildSectionLabel('Partnerships & Collaborations'),
                            const SizedBox(height: 12),
                            _buildPartnershipCard(
                              name: 'N/A',
                              logoPath: 'assets/images/my_profile.png',
                            ),
                            _buildPartnershipCard(
                              name: 'N/A',
                              logoPath: 'assets/images/my_profile.png',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header implementation matching Proof of Payment style
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: royalBlue),
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(
                    text: 'About ',
                    style: TextStyle(color: royalBlue),
                  ),
                  TextSpan(
                    text: 'Vouch',
                    style: TextStyle(color: gold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Central logo section
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: royalBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: royalBlue.withOpacity(0.08), width: 2),
            ),
            child: Image.asset(
              'assets/logos/vouch_logo.png',
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vouch App',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: royalBlue,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Software Solution',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: royalBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generic section label
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: royalBlue,
      ),
    );
  }

  /// Card-based content section matching Transfer Card style
  Widget _buildCardSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: royalBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  /// Developer card implementation matching the app's standard layout
  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/jeslitogeverola.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Ionicons.person, color: royalBlue);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jeslito G. Geverola',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Software Developer',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: royalBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'BS in Information Technology',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Partnership card implementation
  Widget _buildPartnershipCard({
    required String name,
    required String logoPath,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: royalBlue.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: royalBlue.withOpacity(0.05),
              border: Border.all(color: royalBlue.withOpacity(0.1), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                logoPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Ionicons.business_outline,
                    color: royalBlue,
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
