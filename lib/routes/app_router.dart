import 'package:flutter/material.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/home/screens/admin_home_screen.dart';
import '../features/home/screens/student_home_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String studentHome = '/student-home';
  static const String adminHome = '/admin-home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeScreen());
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
