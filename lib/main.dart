import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/services/supabase_auth_service.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file.');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const VouchMobileApp());
}

class VouchMobileApp extends StatelessWidget {
  const VouchMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vouch Mobile App',
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