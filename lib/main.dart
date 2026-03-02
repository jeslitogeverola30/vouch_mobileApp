import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
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
    final hasSession = Supabase.instance.client.auth.currentUser != null;

    return MaterialApp(
      title: 'Vouch Mobile App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: hasSession ? AppRouter.studentHome : AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
