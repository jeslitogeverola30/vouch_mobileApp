import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const VouchMobileApp());
}

class VouchMobileApp extends StatelessWidget {
  const VouchMobileApp({super.key});

  static const String publishableKey = 'pk_test_dGlkeS1ndWxsLTQxLmNsZXJrLmFjY291bnRzLmRldiQ';

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: MaterialApp(
        title: 'Vouch Mobile App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
