import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: const [
        _AdminProfileTile(
          icon: Ionicons.person_circle,
          title: 'Account Settings',
          subtitle: 'Manage your admin profile information',
        ),
        SizedBox(height: 12),
        _AdminProfileTile(
          icon: Ionicons.shield_checkmark,
          title: 'Security',
          subtitle: 'Change password and review access logs',
        ),
        SizedBox(height: 12),
        _AdminProfileTile(
          icon: Ionicons.log_out,
          title: 'Sign Out',
          subtitle: 'End your admin session safely',
        ),
      ],
    );
  }
}

class _AdminProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminProfileTile({
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
