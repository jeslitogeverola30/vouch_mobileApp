import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../events/screens/events_main_screen.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const EventsScreen(showChrome: false),
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
