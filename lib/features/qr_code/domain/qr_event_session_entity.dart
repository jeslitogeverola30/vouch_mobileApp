class QrEventSessionEntity {
  const QrEventSessionEntity({
    required this.eventName,
    required this.location,
    required this.timeWindow,
    required this.isActive,
    required this.totalScans,
  });

  final String eventName;
  final String location;
  final String timeWindow;
  final bool isActive;
  final int totalScans;
}
