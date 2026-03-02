import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'admin_event_details_screen.dart';
import '../../events/screens/events_main_screen.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EventsScreen(
          showChrome: false,
          onViewDetailsTap: (context, event) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminEventDetailsScreen(
                  eventImage:
                      event['image'] as String? ??
                      'assets/images/event-siglakas.jpg',
                  eventName: event['name'] as String? ?? 'Event',
                  eventDate: event['date'] as String? ?? 'Date not available',
                  eventTime:
                      'Time in: ${event['timeIn'] as String? ?? 'Time-in not available'}\n'
                      'Time out: ${event['timeOut'] as String? ?? 'Time-out not available'}',
                  isObligatory: event['isObligatory'] as bool? ?? false,
                ),
              ),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: 'admin_events_add_fab',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Add Event tapped')));
            },
            backgroundColor: const Color(0xFF003DA5),
            foregroundColor: Colors.white,
            elevation: 8,
            highlightElevation: 10,
            shape: const CircleBorder(),
            child: const Icon(Ionicons.add, size: 28),
          ),
        ),
      ],
    );
  }
}
