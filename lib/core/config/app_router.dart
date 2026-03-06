import 'package:flutter/material.dart';

import '../../features/auth/presentation/email_verification_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_in_verification_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/change_email_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/presentation/sensitive_reauth_screen.dart';
import '../../features/events/presentation/admin/admin_event_details_screen.dart';
import '../../features/events/presentation/admin/admin_event_record_screen.dart';
import '../../features/profile/presentation/admin/students_database_screen.dart';
import '../../features/profile/presentation/student/activity_card_screen.dart';
import '../layout/admin_main_shell.dart';
import '../layout/student_main_shell.dart';

class AppRouter {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String emailVerification = '/email-verification';
  static const String signInVerification = '/sign-in-verification';
  static const String forgotPassword = '/forgot-password';
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
  static const String adminEventDetails = '/admin-event-details';
  static const String adminEventRecord = '/admin-event-record';

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
      case forgotPassword:
        final email = settings.arguments is String
            ? settings.arguments! as String
            : '';
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(initialEmail: email),
        );
      case events:
        final initialEventsTabIndex = settings.arguments is int
            ? settings.arguments! as int
            : 0;
        return MaterialPageRoute(
          builder: (_) => StudentMainShell(
            initialIndex: 1,
            initialEventsTabIndex: initialEventsTabIndex,
          ),
        );
      case payments:
        return MaterialPageRoute(
          builder: (_) => const StudentMainShell(initialIndex: 3),
        );
      case studentHome:
        return MaterialPageRoute(
          builder: (_) => const StudentMainShell(initialIndex: 0),
        );
      case adminHome:
        final initialAdminTab = settings.arguments is int
            ? settings.arguments! as int
            : 0;
        return MaterialPageRoute(
          builder: (_) => AdminMainShell(initialIndex: initialAdminTab),
        );
      case myQrCode:
        return MaterialPageRoute(
          builder: (_) => const StudentMainShell(initialIndex: 2),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const StudentMainShell(initialIndex: 4),
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
      case adminEventDetails:
        final args = settings.arguments is Map<String, dynamic>
            ? settings.arguments! as Map<String, dynamic>
            : <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => AdminEventDetailsScreen(
            eventId: _readInt(args['eventId']),
            eventImage:
                args['eventImage'] as String? ??
                'assets/images/event-siglakas.jpg',
            eventName: args['eventName'] as String? ?? 'Event',
            eventDate: args['eventDate'] as String? ?? 'Date not available',
            eventTime:
                args['eventTime'] as String? ??
                'Time in: Time-in not available\nTime out: Time-out not available',
            location: args['location'] as String? ?? 'University Campus',
            locationSubtitle: args['locationSubtitle'] as String? ?? '',
            eventDateRaw: args['eventDateRaw'] as String?,
            timeInStartRaw: args['timeInStartRaw'] as String?,
            timeInEndRaw: args['timeInEndRaw'] as String?,
            timeOutStartRaw: args['timeOutStartRaw'] as String?,
            timeOutEndRaw: args['timeOutEndRaw'] as String?,
            shortDescription:
                args['shortDescription'] as String? ??
                'No short description available for this event.',
            description:
                args['description'] as String? ??
                'No description available for this event.',
            isObligatory: args['isObligatory'] as bool? ?? false,
            isTodayEvent: args['isTodayEvent'] as bool? ?? false,
          ),
        );
      case adminEventRecord:
        final args = settings.arguments is Map<String, dynamic>
            ? settings.arguments! as Map<String, dynamic>
            : <String, dynamic>{};
        return MaterialPageRoute(
          builder: (_) => EventRecordScreen(
            eventId: _readInt(args['eventId']),
            eventName: args['eventName'] as String? ?? 'Event',
            eventDate: args['eventDate'] as String? ?? 'Date not available',
            eventDateRaw: args['eventDateRaw'] as String?,
            isEventDone: args['isEventDone'] as bool?,
            eventLocation:
                args['eventLocation'] as String? ?? 'University Campus',
            eventTimeIn: args['eventTimeIn'] as String? ?? '-',
            eventTimeOut: args['eventTimeOut'] as String? ?? '-',
            eventImage:
                args['eventImage'] as String? ??
                'assets/images/event-siglakas.jpg',
            isObligatory: args['isObligatory'] as bool? ?? false,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  static int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }
}
