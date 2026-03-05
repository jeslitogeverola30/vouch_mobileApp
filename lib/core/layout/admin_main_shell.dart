import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/global_header_search.dart';
import '../widgets/admin_bottom_navigation_bar.dart';
import '../widgets/app_main_header.dart';
import '../../features/events/presentation/admin/admin_events_screen.dart';
import '../../features/payments/presentation/admin/admin_payments_screen.dart';
import '../../features/profile/presentation/admin/admin_profile_screen.dart';
import '../../features/student_management/presentation/screens/student_management_screen.dart';
import '../../features/home/screens/admin_home_screen.dart';

class AdminMainShell extends StatefulWidget {
  final int initialIndex;

  const AdminMainShell({super.key, this.initialIndex = 0});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              AppMainHeader(
                avatarPath: 'assets/logos/facet_logo.jpg',
                onAvatarTap: () {
                  if (_currentIndex == 4) {
                    return;
                  }
                  setState(() {
                    _currentIndex = 4;
                  });
                },
                onSearchTap: () => openGlobalHeaderSearch(context),
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: const [
                    AdminHomeScreen(showChrome: false),
                    AdminStudentsScreen(),
                    AdminEventsScreen(showChrome: false),
                    AdminPaymentsScreen(),
                    AdminProfileScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AdminBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex == index) {
              return;
            }
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
