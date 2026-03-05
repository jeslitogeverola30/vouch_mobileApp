import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../data/qr_scanner_seed_data.dart';
import '../../domain/qr_event_session_entity.dart';
import '../../domain/qr_scan_record_entity.dart';
import '../../domain/qr_utils.dart';
import '../providers/qr_scanner_controller.dart';
import '../widgets/qr_count_chip.dart';
import '../widgets/qr_current_event_card.dart';
import '../widgets/qr_recent_scan_card.dart';
import '../widgets/qr_scanner_card.dart';
import '../widgets/qr_section_header.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final QrScannerController _scannerController = QrScannerController();
  final QrEventSessionEntity currentEvent = QrScannerSeedData.currentEvent;
  final List<QrScanRecordEntity> recentScans = QrScannerSeedData.recentScans;

  int get totalScans => currentEvent.totalScans;

  Future<void> _simulateQRScan() async {
    final samplePayload = QrUtils.generateStudentQrPayload(
      studentId: '2025-0102',
      fullName: 'Anna Paulina',
      faculty: 'Faculty of Engineering',
      program: 'BS Civil Engineering',
    );
    final isVerified = await _scannerController.verify(samplePayload);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isVerified ? 'QR code scanned successfully' : 'Invalid QR code',
        ),
        backgroundColor: isVerified
            ? const Color(0xFF2E7D32)
            : const Color(0xFFC62828),
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
  void dispose() {
    _scannerController.dispose();
    super.dispose();
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
                                QrCountChip(label: 'Total', count: totalScans),
                                QrCountChip(
                                  label: 'Successful',
                                  count: _successCount,
                                ),
                                QrCountChip(
                                  label: 'Errors',
                                  count: _errorCount,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const QrSectionHeader(
                      title: 'Current Event',
                      subtitle: 'Active window for attendance capture',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: QrCurrentEventCard(
                        event: currentEvent,
                        onRecordTimeIn: _recordTimeIn,
                        onRecordTimeOut: _recordTimeOut,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const QrSectionHeader(
                      title: 'QR Scanner',
                      subtitle: 'Position the QR code inside the frame',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: QrScannerCard(onScanNow: _simulateQRScan),
                    ),
                    const SizedBox(height: 22),
                    QrSectionHeader(
                      title: 'Recent Scans',
                      subtitle: '${recentScans.length} latest entries',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: recentScans
                            .map((scan) => QrRecentScanCard(scan: scan))
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

  int get _successCount => QrScannerSeedData.successCount(recentScans);

  int get _errorCount => QrScannerSeedData.errorCount(recentScans);
}
