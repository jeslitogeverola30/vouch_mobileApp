// lib/core/config/app_constants.dart

class AppConstants {
  /// The mandatory waiting period between pull-to-refreshes
  static const Duration refreshCooldown = Duration(minutes: 1);
  
  /// The maximum number of manual refreshes a user can perform in a single day
  static const int maxDailyRefreshes = 5;
}