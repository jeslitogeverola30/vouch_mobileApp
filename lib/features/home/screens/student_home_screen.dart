import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/data/local/database_helper.dart';
import '../../../core/utils/global_header_search.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../auth/data/supabase_auth_service.dart';
import '../../events/presentation/student/student_event_details_screen.dart';
import '../../profile/data/supabase_profile_repository_impl.dart';
import '../../../core/config/app_router.dart';

class StudentHomeScreen extends StatefulWidget {
  final bool showChrome;

  const StudentHomeScreen({super.key, this.showChrome = true});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _selectedNavIndex = 0;
  String _studentName = 'Student';
  String? _pressedActionLabel;

  // Mock data for events
  final List<Map<String, String>> todayEvents = [
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentData();
    });
  }

  Future<void> _loadStudentData() async {
    final email = SupabaseAuthService.currentUser?.email;
    if (email == null || email.isEmpty) {
      return;
    }

    Map<String, dynamic>? student;

    try {
      student =
          (await SupabaseProfileRepositoryImpl.instance.getCurrentUserProfile())
              ?.toMap();
    } catch (_) {
      student = null;
    }

    student ??= await DatabaseHelper.instance.getStudentByEmail(email);

    if (student == null || !mounted) {
      return;
    }

    final fullName = (student['full_name'] as String? ?? '').trim();
    final firstName = fullName.isEmpty ? 'Student' : fullName.split(' ').first;

    setState(() {
      _studentName = firstName;
    });
  }

  void _openMyQr() {
    Navigator.pushReplacementNamed(context, AppRouter.myQrCode);
  }

  void _openPayments() {
    Navigator.pushReplacementNamed(context, AppRouter.payments);
  }

  void _openRateEvent() {
    Navigator.pushReplacementNamed(context, AppRouter.events, arguments: 3);
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
            // Decorative background shapes
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
        bottomNavigationBar: widget.showChrome
            ? AppBottomNavigationBar(
                currentIndex: _selectedNavIndex,
                onTap: (index) {
                  if (index == _selectedNavIndex) {
                    return;
                  }

                  if (index == 1) {
                    Navigator.pushReplacementNamed(context, AppRouter.events);
                    return;
                  }

                  if (index == 2) {
                    Navigator.pushReplacementNamed(context, AppRouter.myQrCode);
                    return;
                  }

                  if (index == 3) {
                    Navigator.pushReplacementNamed(context, AppRouter.payments);
                    return;
                  }

                  if (index == 4) {
                    Navigator.pushReplacementNamed(context, AppRouter.profile);
                    return;
                  }

                  setState(() {
                    _selectedNavIndex = index;
                  });
                },
              )
            : null,
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
                _buildGreetingSection(),
                const SizedBox(height: 24),
                _buildTodaysEventSection(),
                const SizedBox(height: 20),
                _buildQuickActionsSection(),
                const SizedBox(height: 24),
                _buildStatisticsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
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
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Hello, ',
                    style: TextStyle(
                      color: Color(0xFF003DA5),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: _studentName,
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
              'Have a great day ka-TATA',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF003DA5).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${todayEvents.length} events lined up today',
                style: const TextStyle(
                  color: Color(0xFF003DA5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysEventSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: "Today's Event",
          subtitle: 'Join and participate in campus activities',
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 258,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: todayEvents.length,
            itemBuilder: (context, index) {
              final event = todayEvents[index];
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(
                        eventImage:
                            event['image'] ?? 'assets/images/panaghigalaay.jpg',
                        eventName: event['name'] ?? 'Event',
                        eventDate: event['date'] ?? 'Date not available',
                        eventTime:
                            'Time in: ${event['timeIn'] ?? 'Time-in not available'}\n'
                            'Time out: ${event['timeOut'] ?? 'Time-out not available'}',
                        description:
                            event['description'] ??
                            'No description available for this event.',
                        isObligatory: false,
                      ),
                    ),
                  );
                },
                child: Container(
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
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                              'Time in: ${event['timeIn']}',
                              style: const TextStyle(
                                color: Color(0xFF003DA5),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Time out: ${event['timeOut']}',
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Quick Actions',
          subtitle: 'Access your most-used features quickly',
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Ionicons.qr_code,
                  label: 'My QR',
                  isHighlighted: true,
                  onTap: _openMyQr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Ionicons.wallet,
                  label: 'Payments',
                  onTap: _openPayments,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Ionicons.star,
                  label: 'Ratings',
                  onTap: _openRateEvent,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildStatisticsSection() {
    return Padding(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Rate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '85%',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
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
}
