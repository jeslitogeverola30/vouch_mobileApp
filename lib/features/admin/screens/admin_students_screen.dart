import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AdminStudentsScreen extends StatelessWidget {
  const AdminStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        _AdminSectionCard(
          icon: Ionicons.people,
          title: 'Students Overview',
          subtitle: '1,256 active student records',
        ),
        const SizedBox(height: 12),
        _AdminSectionCard(
          icon: Ionicons.person_add,
          title: 'Pending Registrations',
          subtitle: '12 accounts waiting for verification',
        ),
        const SizedBox(height: 12),
        _AdminSectionCard(
          icon: Ionicons.download,
          title: 'Export Records',
          subtitle: 'Generate CSV for student reports',
        ),
      ],
    );
  }
}

class _AdminSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminSectionCard({
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
              color: const Color(0xFF003DA5).withOpacity(0.08),
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
