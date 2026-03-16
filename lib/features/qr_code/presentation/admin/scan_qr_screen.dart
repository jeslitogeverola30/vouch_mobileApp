import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/qr_event_attendance_service.dart';
import '../../domain/qr_event_session_entity.dart';
import '../../domain/qr_scan_record_entity.dart';
import '../providers/qr_scanner_controller.dart';
import '../widgets/qr_count_chip.dart';
import '../widgets/qr_current_event_card.dart';
import '../widgets/qr_recent_scan_card.dart';
import '../widgets/qr_scanner_card.dart';
import '../widgets/qr_section_header.dart';

enum _ScanMode { timeIn, timeOut }

class ScanQrScreen extends StatefulWidget {
  final int? eventId;
  final String eventName;
  final String location;
  final String timeWindow;
  final bool isEventActive;

  const ScanQrScreen({
    super.key,
    this.eventId,
    this.eventName = 'Event',
    this.location = 'University Campus',
    this.timeWindow = 'Time in: -  •  Time out: -',
    this.isEventActive = true,
  });

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final QrScannerController _scannerController = QrScannerController();
  late final MobileScannerController _mobileScannerController;
  final QrEventAttendanceService _attendanceService =
      QrEventAttendanceService.instance;

  late QrEventSessionEntity _currentEvent;
  List<QrScanRecordEntity> _recentScans = const [];
  bool _isLoadingAttendance = false;
  bool _isSavingScan = false;
  _ScanMode _scanMode = _ScanMode.timeIn;
  String _lastScannedRawValue = '';
  DateTime? _lastScannedAt;
  bool _showScannerInitHelp = false;
  Timer? _scannerInitTimer;

  int get totalScans => _currentEvent.totalScans;

  @override
  void initState() {
    super.initState();

    _mobileScannerController = MobileScannerController(
      autoStart: true,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 300,
    );
    _mobileScannerController.addListener(_onScannerStateChanged);

    _currentEvent = _buildCurrentEvent(totalScans: 0);
    _loadAttendanceSummary();
    _scheduleScannerInitHelp();
  }

  Future<void> _handleDetectedQr(String rawValue) async {
    final normalized = rawValue.trim();
    if (normalized.isEmpty || _isSavingScan) {
      return;
    }

    final now = DateTime.now();
    final lastAt = _lastScannedAt;
    if (lastAt != null &&
        _lastScannedRawValue == normalized &&
        now.difference(lastAt) < const Duration(seconds: 2)) {
      return;
    }

    _lastScannedRawValue = normalized;
    _lastScannedAt = now;

    await _processScannedQr(normalized);
  }

  Future<void> _processScannedQr(String rawValue) async {
    if (_isSavingScan) {
      return;
    }

    final eventId = widget.eventId;
    if (eventId == null) {
      _showSnack(
        message: 'Missing event ID. Open this scanner from Event Details.',
        backgroundColor: const Color(0xFFC62828),
      );
      return;
    }

    setState(() => _isSavingScan = true);

    final isVerified = await _scannerController.verify(rawValue);
    final payload = _scannerController.lastPayload;

    if (!mounted) {
      return;
    }

    if (!isVerified || payload == null) {
      _prependLocalScan(
        QrScanRecordEntity(
          name: 'Unknown Student',
          studentId: '-',
          program: 'N/A',
          time: _formatDisplayTime(DateTime.now()),
          status: 'error',
          type: _scanModeLabel,
        ),
      );

      setState(() => _isSavingScan = false);
      await _emitScanFeedback(success: false);
      _showSnack(
        message: 'Invalid QR code',
        backgroundColor: const Color(0xFFC62828),
      );
      return;
    }

    final result = await _attendanceService.recordScan(
      eventId: eventId,
      studentId: payload.studentId,
      mode: _scanMode == _ScanMode.timeIn
          ? AttendanceScanMode.timeIn
          : AttendanceScanMode.timeOut,
    );

    if (!mounted) {
      return;
    }

    _prependLocalScan(
      QrScanRecordEntity(
        name: payload.fullName.isEmpty ? payload.studentId : payload.fullName,
        studentId: payload.studentId,
        program: payload.program.isEmpty ? 'N/A' : payload.program,
        time: _formatDisplayTime(result.scannedAt?.toLocal() ?? DateTime.now()),
        status: result.success ? 'success' : 'error',
        type: _scanModeLabel,
      ),
    );

    if (result.success) {
      await _loadAttendanceSummary(showLoader: false);
    }

    setState(() => _isSavingScan = false);
    await _emitScanFeedback(success: result.success);

    _showSnack(
      message: result.message,
      backgroundColor: result.success
          ? const Color(0xFF2E7D32)
          : const Color(0xFFC62828),
    );
  }

  void _recordTimeIn() {
    setState(() => _scanMode = _ScanMode.timeIn);
    _showSnack(
      message: 'Scanner mode set to Time In',
      backgroundColor: const Color(0xFF003DA5),
    );
  }

  void _recordTimeOut() {
    setState(() => _scanMode = _ScanMode.timeOut);
    _showSnack(
      message: 'Scanner mode set to Time Out',
      backgroundColor: const Color(0xFF003DA5),
    );
  }

  Future<void> _loadAttendanceSummary({bool showLoader = true}) async {
    final eventId = widget.eventId;
    if (eventId == null) {
      return;
    }

    if (showLoader && mounted) {
      setState(() => _isLoadingAttendance = true);
    }

    try {
      final summary = await _attendanceService.fetchEventAttendanceSummary(
        eventId: eventId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentEvent = _buildCurrentEvent(totalScans: summary.totalScans);
        _recentScans = summary.recentScans;
        _isLoadingAttendance = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoadingAttendance = false);
    }
  }

  QrEventSessionEntity _buildCurrentEvent({required int totalScans}) {
    final normalizedName = widget.eventName.trim();
    final normalizedLocation = widget.location.trim();
    final normalizedTimeWindow = widget.timeWindow.trim();

    return QrEventSessionEntity(
      eventName: normalizedName.isEmpty ? 'Event' : normalizedName,
      location: normalizedLocation.isEmpty
          ? 'University Campus'
          : normalizedLocation,
      timeWindow: normalizedTimeWindow.isEmpty
          ? 'Time in: -  •  Time out: -'
          : normalizedTimeWindow,
      isActive: widget.isEventActive,
      totalScans: totalScans,
    );
  }

  void _prependLocalScan(QrScanRecordEntity scan) {
    setState(() {
      _recentScans = [scan, ..._recentScans].take(12).toList();
    });
  }

  String get _scanModeLabel {
    return _scanMode == _ScanMode.timeIn ? 'Time In' : 'Time Out';
  }

  String _formatDisplayTime(DateTime value) {
    final hour24 = value.hour;
    final minuteText = value.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

    return '$hour12:$minuteText $period';
  }

  void _showSnack({required String message, required Color backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _emitScanFeedback({required bool success}) async {
    if (success) {
      await HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      return;
    }

    await HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _restartScannerPreview() async {
    _lastScannedRawValue = '';
    _lastScannedAt = null;

    if (mounted) {
      setState(() => _showScannerInitHelp = false);
    }

    _scheduleScannerInitHelp();

    try {
      await _mobileScannerController.stop();
    } catch (_) {}

    try {
      await _mobileScannerController.start();
    } catch (_) {}
  }

  void _scheduleScannerInitHelp() {
    _scannerInitTimer?.cancel();
    _scannerInitTimer = Timer(const Duration(seconds: 6), () {
      if (!mounted) {
        return;
      }

      final state = _mobileScannerController.value;
      if (!state.isInitialized && state.error == null) {
        setState(() => _showScannerInitHelp = true);
      }
    });
  }

  void _onScannerStateChanged() {
    if (!mounted) {
      return;
    }

    final state = _mobileScannerController.value;
    if (state.isInitialized || state.error != null) {
      _scannerInitTimer?.cancel();
      if (_showScannerInitHelp) {
        setState(() => _showScannerInitHelp = false);
      }
    }
  }

  @override
  void dispose() {
    _scannerInitTimer?.cancel();
    _mobileScannerController.removeListener(_onScannerStateChanged);
    _mobileScannerController.dispose();
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
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                    size: 21,
                                  ),
                                ),
                              ),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Scan ',
                                      style: TextStyle(
                                        color: Color(0xFF003DA5),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'QR',
                                      style: TextStyle(
                                        color: Color(0xFFFFC107),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (widget.eventId == null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC62828).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFC62828).withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'This scanner was opened without an event context. Go back and open it from Event Details.',
                            style: TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const QrSectionHeader(
                      title: 'Current Event',
                      subtitle: 'Active window for attendance capture',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: QrCurrentEventCard(
                        event: _currentEvent,
                        isTimeInActive: _scanMode == _ScanMode.timeIn,
                        onRecordTimeIn: _recordTimeIn,
                        onRecordTimeOut: _recordTimeOut,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const QrSectionHeader(
                      title: 'QR Scanner',
                      subtitle:
                          'Position the QR inside the frame and start scan',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          QrCountChip(label: 'Total', count: totalScans),
                          QrCountChip(
                            label: 'Successful',
                            count: _successCount,
                          ),
                          QrCountChip(label: 'Errors', count: _errorCount),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003DA5).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF003DA5).withOpacity(0.12),
                          ),
                        ),
                        child: Text(
                          'Current Scan Mode: $_scanModeLabel',
                          style: const TextStyle(
                            color: Color(0xFF003DA5),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: QrScannerCard(
                        scannerController: _mobileScannerController,
                        onCodeDetected: _handleDetectedQr,
                        onRetryTap: () {
                          _restartScannerPreview();
                        },
                        isProcessing: _isSavingScan,
                        scanModeLabel: _scanModeLabel,
                      ),
                    ),
                    if (_showScannerInitHelp)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFC107).withOpacity(0.45),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Camera is taking longer than expected to initialize.',
                                style: TextStyle(
                                  color: Color(0xFF6D4C00),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Check camera permission, then tap Retry Camera.',
                                style: TextStyle(
                                  color: Color(0xFF6D4C00),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _restartScannerPreview();
                                  },
                                  icon: const Icon(Ionicons.refresh, size: 16),
                                  label: const Text('Retry Camera'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF003DA5),
                                    side: BorderSide(
                                      color: const Color(
                                        0xFF003DA5,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    QrSectionHeader(
                      title: 'Recent Scans',
                      subtitle: '${_recentScans.length} latest entries',
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _isLoadingAttendance && _recentScans.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : _recentScans.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF003DA5,
                                  ).withOpacity(0.1),
                                ),
                              ),
                              child: const Text(
                                'No scans recorded yet for this event.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Column(
                              children: _recentScans
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

  int get _successCount {
    return _recentScans.where((scan) => scan.status == 'success').length;
  }

  int get _errorCount {
    return _recentScans.where((scan) => scan.status == 'error').length;
  }
}
