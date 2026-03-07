import 'package:flutter/material.dart';

import 'core/config/app_router.dart';
import 'core/config/app_strings.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/supabase_auth_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientService.initialize();
  await LocalNotificationService.instance.initialize();
  LocalNotificationService.instance.attachNavigatorKey(appNavigatorKey);

  runApp(const VouchMobileApp());
}

class VouchMobileApp extends StatelessWidget {
  const VouchMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _StartupGate(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeUser());
  }

  Future<void> _routeUser() async {
    if (!mounted) return;

    final hasSession = SupabaseAuthService.currentUser != null;
    if (!hasSession) {
      _goTo(AppRouter.login);
      return;
    }

    try {
      final role = await SupabaseAuthService.determineUserRole();
      if (!mounted) return;

      if (role == 'admin') {
        _goTo(AppRouter.adminHome);
        return;
      }

      _goTo(AppRouter.studentHome);
    } catch (_) {
      await SupabaseAuthService.signOut();
      if (!mounted) return;
      _goTo(AppRouter.login);
    }
  }

  void _goTo(String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}


//This is the copy of a stable version of the project, which is used for testing and development purposes. It may not contain 