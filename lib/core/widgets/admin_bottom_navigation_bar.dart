import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class AdminBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          iconSize: 22,
          selectedItemColor: const Color(0xFF003DA5),
          unselectedItemColor: Colors.grey.shade400,
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 21),
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.home_outline),
              activeIcon: _buildActiveNavIcon(Ionicons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.people_outline),
              activeIcon: _buildActiveNavIcon(Ionicons.people),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.calendar_outline),
              activeIcon: _buildActiveNavIcon(Ionicons.calendar),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.card_outline),
              activeIcon: _buildActiveNavIcon(Ionicons.card),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.person_outline),
              activeIcon: _buildActiveNavIcon(Ionicons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveNavIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon),
    );
  }
}
