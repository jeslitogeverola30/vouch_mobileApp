import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/global_header_search.dart';
import '../../../core/widgets/admin_bottom_navigation_bar.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../admin/screens/admin_events_screen.dart';
import '../../admin/screens/admin_payments_screen.dart';
import '../../admin/screens/admin_profile_screen.dart';
import '../../admin/screens/admin_students_screen.dart';
import '../../home/screens/admin_home_screen.dart';

class AdminMainShellScreen extends StatefulWidget {
  final int initialIndex;

  const AdminMainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<AdminMainShellScreen> createState() => _AdminMainShellScreenState();
}

class _AdminMainShellScreenState extends State<AdminMainShellScreen> {
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
              AppMainHeader(onSearchTap: () => openGlobalHeaderSearch(context)),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: const [
                    AdminHomeScreen(showChrome: false),
                    AdminStudentsScreen(),
                    AdminEventsScreen(),
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
