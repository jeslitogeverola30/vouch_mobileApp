class EventFormInitialData {
  const EventFormInitialData({
    required this.eventId,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.location,
    required this.imageUrl,
    required this.eventDate,
    required this.timeInStartMinutes,
    required this.timeInEndMinutes,
    required this.timeOutStartMinutes,
    required this.timeOutEndMinutes,
    required this.isMandatory,
  });

  final int eventId;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final String location;
  final String imageUrl;
  final DateTime eventDate;
  final int timeInStartMinutes;
  final int timeInEndMinutes;
  final int timeOutStartMinutes;
  final int timeOutEndMinutes;
  final bool isMandatory;
}
