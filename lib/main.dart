import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_router.dart';
import 'core/config/app_strings.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/supabase_auth_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await SupabaseClientService.initialize(
    supabaseUrl: _requiredEnv('SUPABASE_URL'),
    supabaseAnonKey: _requiredEnv('SUPABASE_ANON_KEY'),
  );

  LocalNotificationService.instance.attachNavigatorKey(appNavigatorKey);
  unawaited(_initializeNotifications());

  runApp(const VouchMobileApp());
}

Future<void> _initializeNotifications() async {
  try {
    await LocalNotificationService.instance.initialize();
  } catch (_) {}
}

String _requiredEnv(String key) {
  final rawValue = dotenv.env[key];
  if (rawValue == null) {
    throw Exception('Missing $key in .env file.');
  }

  var value = rawValue.trim();
  if (value.isEmpty) {
    throw Exception('Missing $key in .env file.');
  }

  final wrappedInSingleQuotes =
      value.length >= 2 && value.startsWith("'") && value.endsWith("'");
  final wrappedInDoubleQuotes =
      value.length >= 2 && value.startsWith('"') && value.endsWith('"');

  if (wrappedInSingleQuotes || wrappedInDoubleQuotes) {
    value = value.substring(1, value.length - 1).trim();
  }

  if (value.isEmpty) {
    throw Exception('Missing $key in .env file.');
  }

  return value;
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
      final role = await SupabaseAuthService.determineUserRole().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;

      if (role == 'admin') {
        _goTo(AppRouter.adminHome);
        return;
      }

      _goTo(AppRouter.studentHome);
    } catch (_) {
      try {
        await SupabaseAuthService.signOut();
      } catch (_) {}

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