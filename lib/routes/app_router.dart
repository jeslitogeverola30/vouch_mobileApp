import 'package:flutter/material.dart';

import '../features/auth/screens/email_verification_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_in_verification_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/home/screens/admin_home_screen.dart';
import '../features/main/screens/main_shell_screen.dart';
import '../features/profile/screens/activity_card_screen.dart';
import '../features/profile/screens/change_email_screen.dart';
import '../features/profile/screens/change_password_screen.dart';
import '../features/profile/screens/sensitive_reauth_screen.dart';
import '../features/profile/screens/students_database_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String emailVerification = '/email-verification';
  static const String signInVerification = '/sign-in-verification';
  static const String events = '/events';
  static const String payments = '/payments';
  static const String studentHome = '/student-home';
  static const String adminHome = '/admin-home';
  static const String myQrCode = '/my-qr-code';
  static const String profile = '/profile';
  static const String activityCard = '/activity-card';
  static const String sensitiveReauth = '/sensitive-reauth';
  static const String changeEmail = '/change-email';
  static const String changePassword = '/change-password';
  static const String studentsDatabase = '/students-database';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case emailVerification:
        final email = settings.arguments is String
            ? settings.arguments! as String
            : '';
        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        );
      case signInVerification:
        final email = settings.arguments is String
            ? settings.arguments! as String
            : '';
        return MaterialPageRoute(
          builder: (_) => SignInVerificationScreen(email: email),
        );
      case events:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(initialIndex: 1),
        );
      case payments:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(initialIndex: 3),
        );
      case studentHome:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(initialIndex: 0),
        );
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case myQrCode:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(initialIndex: 2),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const MainShellScreen(initialIndex: 4),
        );
      case activityCard:
        return MaterialPageRoute(builder: (_) => const ActivityCardScreen());
      case sensitiveReauth:
        final nextRoute = settings.arguments is String
            ? settings.arguments! as String
            : changeEmail;
        return MaterialPageRoute(
          builder: (_) => SensitiveReauthScreen(nextRoute: nextRoute),
        );
      case changeEmail:
        return MaterialPageRoute(builder: (_) => const ChangeEmailScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case studentsDatabase:
        return MaterialPageRoute(
          builder: (_) => const StudentsDatabaseScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
