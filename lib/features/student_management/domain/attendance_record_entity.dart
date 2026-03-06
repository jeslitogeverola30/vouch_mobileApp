class AttendanceRecordEntity {
  const AttendanceRecordEntity({
    required this.studentId,
    required this.studentName,
    required this.eventName,
    required this.status,
    required this.recordedAt,
  });

  final String studentId;
  final String studentName;
  final String eventName;
  final String status;
  final DateTime recordedAt;
}
