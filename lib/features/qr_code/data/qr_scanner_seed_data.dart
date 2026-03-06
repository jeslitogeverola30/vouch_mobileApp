import '../domain/qr_event_session_entity.dart';
import '../domain/qr_scan_record_entity.dart';

class QrScannerSeedData {
  const QrScannerSeedData._();

  static const QrEventSessionEntity currentEvent = QrEventSessionEntity(
    eventName: 'Siglakas 2026 Day 2',
    location: 'University Campus',
    timeWindow: '08:00 AM - 08:15 AM',
    isActive: true,
    totalScans: 142,
  );

  static const List<QrScanRecordEntity> recentScans = [
    QrScanRecordEntity(
      name: 'Anna Paulina',
      studentId: '2025-0102',
      program: 'BS Civil Engineering',
      time: '08:10 AM',
      status: 'success',
      type: 'Time In',
    ),
    QrScanRecordEntity(
      name: 'Basilio Sisa',
      studentId: '2025-0103',
      program: 'BS Computer Science',
      time: '08:12 AM',
      status: 'error',
      type: 'Time In',
    ),
    QrScanRecordEntity(
      name: 'Maria Santos',
      studentId: '2025-0110',
      program: 'BS Information Technology',
      time: '08:14 AM',
      status: 'success',
      type: 'Time Out',
    ),
  ];

  static int successCount(List<QrScanRecordEntity> scans) {
    return scans.where((scan) => scan.status == 'success').length;
  }

  static int errorCount(List<QrScanRecordEntity> scans) {
    return scans.where((scan) => scan.status == 'error').length;
  }
}
