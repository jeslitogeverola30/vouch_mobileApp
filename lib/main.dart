import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_router.dart';
import 'core/config/app_strings.dart';
import 'core/services/local_notification_service.dart';
import 'core/services/supabase_client.dart';
import 'core/theme/app_theme.dart';

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
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}


//This is the copy of a stable version of the project, which is used for testing and development purposes. It may not contain 