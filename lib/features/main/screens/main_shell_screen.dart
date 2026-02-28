import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../events/screens/events_main_screen.dart';
import '../../home/screens/student_home_screen.dart';
import '../../payments/screens/payment_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../qr_code/screens/my_qr_code_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
              const AppMainHeader(),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: const [
                    StudentHomeScreen(showChrome: false),
                    EventsScreen(showChrome: false),
                    QRScreen(showChrome: false),
                    PaymentsScreen(showChrome: false),
                    ProfileScreen(showChrome: false),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == _currentIndex) {
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
