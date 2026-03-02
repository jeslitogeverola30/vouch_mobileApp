import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: const [
        _AdminEventsCard(
          icon: Ionicons.calendar,
          title: 'Today\'s Events',
          subtitle: '2 events are currently open for attendance',
        ),
        SizedBox(height: 12),
        _AdminEventsCard(
          icon: Ionicons.create,
          title: 'Draft Event Setup',
          subtitle: 'Create and publish new campus events',
        ),
        SizedBox(height: 12),
        _AdminEventsCard(
          icon: Ionicons.checkmark_done,
          title: 'Attendance Validation',
          subtitle: 'Review flagged scans and manual check-ins',
        ),
      ],
    );
  }
}

class _AdminEventsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminEventsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF003DA5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
