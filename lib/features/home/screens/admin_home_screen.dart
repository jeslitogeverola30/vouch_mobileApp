import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/utils/global_header_search.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../../routes/app_router.dart';

class AdminHomeScreen extends StatefulWidget {
  final bool showChrome;

  const AdminHomeScreen({super.key, this.showChrome = true});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String? _pressedActionLabel;

  final List<Map<String, String>> todayEvents = [
    {
      'name': 'Panaghigalaay 2025',
      'description': 'Join us for a day of celebration',
      'date': 'March 05, 2026',
      'image': 'assets/images/panaghigalaay.jpg',
    },
    {
      'name': 'Buwan ng Wika 2025',
      'description': 'Show your love to Filipino',
      'date': 'March 12, 2026',
      'image': 'assets/images/buwan-ng-wika.jpg',
    },
  ];

  void _openAdminTab(int index) {
    Navigator.pushReplacementNamed(
      context,
      AppRouter.adminHome,
      arguments: index,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF003DA5),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final isPressed = _pressedActionLabel == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onHighlightChanged: (value) {
          if (!mounted) {
            return;
          }
          setState(() {
            _pressedActionLabel = value ? label : null;
          });
        },
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: isPressed
                ? (isHighlighted
                      ? const Color(0xFFE4AF00)
                      : const Color(0xFF003DA5).withOpacity(0.12))
                : (isHighlighted ? const Color(0xFFFFC107) : Colors.white),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFFFFC107)
                  : const Color(0xFF003DA5).withOpacity(0.15),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPressed
                      ? (isHighlighted
                            ? Colors.white.withOpacity(0.48)
                            : const Color(0xFF003DA5).withOpacity(0.14))
                      : (isHighlighted
                            ? Colors.white.withOpacity(0.35)
                            : const Color(0xFF003DA5).withOpacity(0.08)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF003DA5), size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: isHighlighted
                      ? Colors.black87
                      : const Color(0xFF003DA5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 300,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF003DA5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            widget.showChrome
                ? SafeArea(child: _buildMainContent())
                : _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChrome)
          AppMainHeader(onSearchTap: () => openGlobalHeaderSearch(context)),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF003DA5).withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hello, ',
                                style: TextStyle(
                                  color: Color(0xFF003DA5),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'Admin',
                                style: TextStyle(
                                  color: Color(0xFFFFC107),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Manage students, events, and collections efficiently',
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003DA5).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '3 approvals waiting for action',
                            style: TextStyle(
                              color: Color(0xFF003DA5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  title: "Today's Event",
                  subtitle: 'Track active events and attendance windows',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 248,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: todayEvents.length,
                    itemBuilder: (context, index) {
                      final event = todayEvents[index];
                      return Container(
                        width: 224,
                        margin: const EdgeInsets.only(right: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF003DA5).withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14),
                              ),
                              child: Image.asset(
                                event['image']!,
                                width: 224,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['name']!,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event['description']!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    event['date']!,
                                    style: const TextStyle(
                                      color: Color(0xFF003DA5),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  title: 'Quick Actions',
                  subtitle: 'Open your most-used admin tasks',
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Ionicons.person_add,
                          label: 'Add Student',
                          isHighlighted: true,
                          onTap: () => _openAdminTab(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Ionicons.calendar,
                          label: 'Events',
                          onTap: () => _openAdminTab(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          icon: Ionicons.card,
                          label: 'Payments',
                          onTap: () => _openAdminTab(3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  title: 'Statistics',
                  subtitle: 'Current totals for this term',
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003DA5),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Students',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '1,256',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Events',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '7',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
