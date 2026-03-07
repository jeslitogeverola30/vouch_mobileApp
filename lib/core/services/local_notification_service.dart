import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/auth/data/supabase_auth_service.dart';
import '../config/app_router.dart';

enum NotificationNavigationTarget { payments, events, todayEvents }

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const String _channelId = 'vouch_updates_channel';
  static const String _channelName = 'Vouch Updates';
  static const String _channelDescription =
      'Alerts for new fees, new events, and today\'s events.';
  static const int _updatesNotificationId = 4101;
  static const Color _brandBlue = Color(0xFF003DA5);

  static const String _payloadFees = 'fees';
  static const String _payloadEvents = 'events';
  static const String _payloadTodayEvents = 'today_events';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  int _nextNotificationId = _updatesNotificationId;
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _pendingPayload;

  bool get isAndroidPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void attachNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _flushPendingPayload();
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    if (!isAndroidPlatform) {
      _isInitialized = true;
      return;
    }

    const androidInitialization = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialization,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload?.trim();

    if (launchDetails?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      _saveOrHandlePayload(launchPayload);
    }

    _isInitialized = true;
  }

  Future<bool> requestPermissionIfNeeded() async {
    await initialize();

    if (!isAndroidPlatform) {
      return true;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) {
      return false;
    }

    final enabled = await androidPlugin.areNotificationsEnabled();
    if (enabled == true) {
      return true;
    }

    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<bool> showUpdateNotification({
    required String title,
    required String body,
    required NotificationNavigationTarget target,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedBody = body.trim();

    if (normalizedTitle.isEmpty || normalizedBody.isEmpty) {
      return false;
    }

    if (!isAndroidPlatform) {
      return false;
    }

    await initialize();

    final permissionGranted = await requestPermissionIfNeeded();
    if (!permissionGranted) {
      return false;
    }

    final payload = _payloadForTarget(target);

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        color: _brandBlue,
        colorized: true,
        styleInformation: BigTextStyleInformation(
          normalizedBody,
          contentTitle: '<b>$normalizedTitle</b>',
          summaryText: 'Vouch',
        ),
        category: AndroidNotificationCategory.reminder,
      ),
    );

    await _plugin.show(
      _nextNotificationId++,
      normalizedTitle,
      normalizedBody,
      notificationDetails,
      payload: payload,
    );

    return true;
  }

  Future<void> cancelAll() async {
    if (!isAndroidPlatform) {
      return;
    }

    await initialize();
    await _plugin.cancelAll();
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload?.trim();
    if (payload == null || payload.isEmpty) {
      return;
    }

    _saveOrHandlePayload(payload);
  }

  String _payloadForTarget(NotificationNavigationTarget target) {
    if (target == NotificationNavigationTarget.payments) {
      return _payloadFees;
    }

    if (target == NotificationNavigationTarget.todayEvents) {
      return _payloadTodayEvents;
    }

    return _payloadEvents;
  }

  void _saveOrHandlePayload(String payload) {
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }

    _pendingPayload = null;
    unawaited(_navigateFromPayload(payload, navigator));
  }

  void _flushPendingPayload() {
    final payload = _pendingPayload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final latestPayload = _pendingPayload;
      if (latestPayload == null || latestPayload.isEmpty) {
        return;
      }

      _saveOrHandlePayload(latestPayload);
    });
  }

  Future<void> _navigateFromPayload(
    String payload,
    NavigatorState navigator,
  ) async {
    final currentUser = SupabaseAuthService.currentUser;
    if (currentUser == null) {
      navigator.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
      return;
    }

    var role = 'student';
    try {
      role = await SupabaseAuthService.determineUserRole();
    } catch (_) {
      role = 'student';
    }

    final normalizedPayload = payload.trim().toLowerCase();

    if (role == 'admin') {
      if (normalizedPayload == _payloadFees) {
        navigator.pushNamedAndRemoveUntil(
          AppRouter.adminHome,
          (route) => false,
          arguments: 3,
        );
        return;
      }

      navigator.pushNamedAndRemoveUntil(
        AppRouter.adminHome,
        (route) => false,
        arguments: 2,
      );
      return;
    }

    if (normalizedPayload == _payloadFees) {
      navigator.pushNamedAndRemoveUntil(AppRouter.payments, (route) => false);
      return;
    }

    if (normalizedPayload == _payloadTodayEvents) {
      navigator.pushNamedAndRemoveUntil(
        AppRouter.events,
        (route) => false,
        arguments: 0,
      );
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      AppRouter.events,
      (route) => false,
      arguments: 1,
    );
  }
}
