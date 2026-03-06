class QrScanRecordEntity {
  const QrScanRecordEntity({
    required this.name,
    required this.studentId,
    required this.program,
    required this.time,
    required this.status,
    required this.type,
  });

  final String name;
  final String studentId;
  final String program;
  final String time;
  final String status;
  final String type;

  bool get isError => status == 'error';

  String get badgeLabel => isError ? 'Error' : type;
}
