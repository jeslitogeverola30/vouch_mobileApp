import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
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
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
