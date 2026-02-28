import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/global_header_search.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../core/widgets/app_main_header.dart';
import '../../events/screens/events_main_screen.dart';
import '../../home/screens/student_home_screen.dart';
import '../../payments/screens/payment_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../qr_code/screens/my_qr_code_screen.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final int initialEventsTabIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.initialEventsTabIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  DateTime? _lastBackPressedAt;

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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }

          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
            return;
          }

          final now = DateTime.now();
          final pressedRecently =
              _lastBackPressedAt != null &&
              now.difference(_lastBackPressedAt!) <= const Duration(seconds: 2);

          if (pressedRecently) {
            SystemNavigator.pop();
            return;
          }

          _lastBackPressedAt = now;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Press back again to exit'),
                duration: Duration(seconds: 2),
              ),
            );
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                AppMainHeader(
                  onSearchTap: () => openGlobalHeaderSearch(context),
                  onAvatarTap: () {
                    if (_currentIndex == 4) {
                      return;
                    }
                    setState(() {
                      _currentIndex = 4;
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      const StudentHomeScreen(showChrome: false),
                      EventsScreen(
                        showChrome: false,
                        initialTabIndex: widget.initialEventsTabIndex,
                      ),
                      const QRScreen(showChrome: false),
                      const PaymentsScreen(showChrome: false),
                      const ProfileScreen(showChrome: false),
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
      ),
    );
  }
}
