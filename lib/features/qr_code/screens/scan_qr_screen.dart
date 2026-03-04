import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final String currentEventName = 'Siglakas 2026 Day 2';
  final String currentLocation = 'University Campus';
  final String currentTime = '08:00 AM - 08:15 AM';
  final bool isActive = true;

  final List<Map<String, dynamic>> recentScans = [
    {
      'name': 'Anna Paulina',
      'studentId': '2025-0102',
      'program': 'BS Civil Engineering',
      'time': '08:10 AM',
      'status': 'success',
      'type': 'Time In',
    },
    {
      'name': 'Basilio Sisa',
      'studentId': '2025-0103',
      'program': 'BS Computer Science',
      'time': '08:12 AM',
      'status': 'error',
      'type': 'Time In',
    },
    {
      'name': 'Maria Santos',
      'studentId': '2025-0110',
      'program': 'BS Information Technology',
      'time': '08:14 AM',
      'status': 'success',
      'type': 'Time Out',
    },
  ];

  int totalScans = 142;

  void _simulateQRScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code scanned successfully'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _recordTimeIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time In recorded'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _recordTimeOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time Out recorded'),
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 80,
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
                bottom: 200,
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
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF003DA5,
                              ).withOpacity(0.08),
                            ),
                            icon: const Icon(
                              Ionicons.arrow_back,
                              color: Color(0xFF003DA5),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Scan Attendance',
                              style: TextStyle(
                                color: Color(0xFF003DA5),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF003DA5).withOpacity(0.1),
                          ),
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
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Attendance ',
                                    style: TextStyle(
                                      color: Color(0xFF003DA5),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Scanner',
                                    style: TextStyle(
                                      color: Color(0xFFFFC107),
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Scan student QR codes and record attendance instantly',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildCountChip('Total', totalScans),
                                _buildCountChip('Successful', _successCount),
                                _buildCountChip('Errors', _errorCount),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildSectionHeader(
                      title: 'Current Event',
                      subtitle: 'Active window for attendance capture',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildCurrentEventCard(),
                    ),
                    const SizedBox(height: 22),
                    _buildSectionHeader(
                      title: 'QR Scanner',
                      subtitle: 'Position the QR code inside the frame',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildScannerCard(),
                    ),
                    const SizedBox(height: 22),
                    _buildSectionHeader(
                      title: 'Recent Scans',
                      subtitle: '${recentScans.length} latest entries',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: recentScans
                            .map((scan) => _buildRecentScanCard(scan))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _successCount =>
      recentScans.where((scan) => scan['status'] == 'success').length;

  int get _errorCount =>
      recentScans.where((scan) => scan['status'] == 'error').length;

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

  Widget _buildCountChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(
          color: Color(0xFF003DA5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCurrentEventCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  currentEventName,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      (isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF455A64))
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isActive ? 'Active' : 'Closed',
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF455A64),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Ionicons.location_outline,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                currentLocation,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Ionicons.time_outline,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                currentTime,
                style: const TextStyle(
                  color: Color(0xFF003DA5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _recordTimeIn,
                  icon: const Icon(Ionicons.log_in, size: 17),
                  label: const Text('Time In'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF003DA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _recordTimeOut,
                  icon: const Icon(Ionicons.log_out, size: 17),
                  label: const Text('Time Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF003DA5),
                    side: BorderSide(
                      color: const Color(0xFF003DA5).withOpacity(0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5).withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFC107), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Ionicons.scan_circle,
                    size: 70,
                    color: Color(0xFF003DA5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Align QR code within the frame to scan',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _simulateQRScan,
              icon: const Icon(Ionicons.scan, size: 18),
              label: const Text('Scan Now'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF003DA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanCard(Map<String, dynamic> scan) {
    final isError = scan['status'] == 'error';
    final statusColor = isError
        ? const Color(0xFFC62828)
        : const Color(0xFF2E7D32);
    final name = scan['name'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF003DA5).withOpacity(0.12),
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Color(0xFF003DA5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${scan['studentId']} • ${scan['program']}',
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                scan['time'] as String,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isError ? 'Error' : (scan['type'] as String),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'ST';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
