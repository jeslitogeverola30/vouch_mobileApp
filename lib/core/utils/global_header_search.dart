import 'package:flutter/material.dart';

import '../../features/events/screens/event_details_screen.dart';
import '../../features/home/widgets/student_event_search_delegate.dart';

const List<Map<String, String>> _globalSearchableEvents = [
  {
    'image': 'assets/images/panaghigalaay.jpg',
    'name': 'Panaghigalaay 2025',
    'date': 'March 05, 2026',
    'timeIn': '08:00 AM - 08:15 AM',
    'timeOut': '04:00 PM - 04:15 PM',
    'description': 'Join us for a day of celebration',
  },
  {
    'image': 'assets/images/buwan-ng-wika.jpg',
    'name': 'Buwan ng Wika 2025',
    'date': 'March 12, 2026',
    'timeIn': '08:00 AM - 08:15 AM',
    'timeOut': '04:00 PM - 04:15 PM',
    'description': 'Show your love to Filipino',
  },
];

Future<void> openGlobalHeaderSearch(BuildContext context) async {
  final selectedEvent = await showSearch<Map<String, String>?>(
    context: context,
    delegate: StudentEventSearchDelegate(events: _globalSearchableEvents),
  );

  if (!context.mounted || selectedEvent == null) {
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EventDetailsScreen(
        eventImage: selectedEvent['image'] ?? 'assets/images/panaghigalaay.jpg',
        eventName: selectedEvent['name'] ?? 'Event',
        eventDate: selectedEvent['date'] ?? 'Date not available',
        eventTime:
            'Time in: ${selectedEvent['timeIn'] ?? 'Time-in not available'}\n'
            'Time out: ${selectedEvent['timeOut'] ?? 'Time-out not available'}',
        description:
            selectedEvent['description'] ??
            'No description available for this event.',
        isObligatory: false,
      ),
    ),
  );
}
