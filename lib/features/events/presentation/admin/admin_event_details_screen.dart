import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../qr_code/presentation/admin/scan_qr_screen.dart';

class AdminEventDetailsScreen extends StatelessWidget {
  final String eventImage;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String location;
  final String locationSubtitle;
  final String description;
  final bool isObligatory;

  const AdminEventDetailsScreen({
    super.key,
    this.eventImage = 'assets/images/event-siglakas.jpg',
    this.eventName = 'Siglakas 2026 Day 2',
    this.eventDate = 'April 11, 2026',
    this.eventTime =
        'Time in: 08:00 AM - 08:15 AM\nTime out: 04:00 PM - 04:15 PM',
    this.location = 'University Campus',
    this.locationSubtitle = 'Davao Oriental State University',
    this.description =
        'Join us for SIGLAKAS 2025, the much-awaited annual sports fest that unites Carolinians through friendly competition, teamwork, and the true spirit of sportsmanship. For one exhilarating week, students from different colleges – Engineering, Business, Architecture, Arts and Sciences, Education, and Nursing – will compete across various sports and recreational activities. SIGLAKAS is more than just a tournament — it\'s a celebration of unity, discipline, and pride as students push their limits on and off the field.',
    this.isObligatory = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color royalBlue = Color(0xFF003DA5);
    const Color gold = Color(0xFFFFC107);
    const Color lightGray = Color(0xFF9CA3AF);

    return Scaffold(
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
                color: gold.withOpacity(0.15),
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
                color: royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                            icon: const Icon(
                              Ionicons.arrow_back,
                              color: Color(0xFF003DA5),
                            ),
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
                                text: 'Event ',
                                style: TextStyle(color: Color(0xFF003DA5)),
                              ),
                              TextSpan(
                                text: 'Details',
                                style: TextStyle(color: Color(0xFFFFC107)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEventImage(),
                          const SizedBox(height: 16),
                          _buildTitleRow(),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            icon: Ionicons.calendar,
                            iconBgColor: gold.withOpacity(0.12),
                            iconColor: gold,
                            title: eventDate,
                            subtitle: eventTime,
                            subtitleColor: lightGray,
                          ),
                          const SizedBox(height: 14),
                          _buildInfoCard(
                            icon: Ionicons.location,
                            iconBgColor: royalBlue.withOpacity(0.1),
                            iconColor: royalBlue,
                            title: location,
                            subtitle: locationSubtitle,
                            subtitleColor: lightGray,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              color: royalBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_event_details_scan_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanQrScreen()),
          );
        },
        backgroundColor: const Color(0xFF003DA5),
        foregroundColor: Colors.white,
        elevation: 8,
        highlightElevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Ionicons.scan, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEventImage() {
    final isAssetImage = eventImage.startsWith('assets/');

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: isAssetImage
            ? Image.asset(
                eventImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Ionicons.image,
                        color: Color(0xFF9CA3AF),
                        size: 46,
                      ),
                    ),
                  );
                },
              )
            : Image.network(
                eventImage,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(
                        Ionicons.image,
                        color: Color(0xFF9CA3AF),
                        size: 46,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            eventName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: const Color(0xFF003DA5),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (isObligatory) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'OBLIGATORY',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: subtitleColor,
                    fontSize: 13,
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
}
