class EventDateTimeFormatters {
  EventDateTimeFormatters._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String displayDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String databaseDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  static String databaseTimeFromMinutes(int minutes) {
    final normalizedMinutes = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60);
    final hour = (normalizedMinutes ~/ 60).toString().padLeft(2, '0');
    final minute = (normalizedMinutes % 60).toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  static String buildEventTimeText({
    required String? timeIn,
    required String? timeOut,
  }) {
    final safeTimeIn = timeIn ?? 'Time-in not available';
    final safeTimeOut = timeOut ?? 'Time-out not available';

    return 'Time in: $safeTimeIn\nTime out: $safeTimeOut';
  }
}
