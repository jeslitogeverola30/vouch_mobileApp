import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const String _updatesGroupKey = 'vouch_updates_group';
  static const String _notificationSmallIcon =
      '@drawable/ic_notification_vouch';
  static const String _notificationLargeLogoAsset =
      'assets/logos/vouch_logo.png';
  static const int _updatesNotificationId = 4101;
  static const Color _brandBlue = Color(0xFF003DA5);
  static const Color _brandGold = Color(0xFFFFC107);
  static const String _appLabel = 'Vouch';

  static const String _payloadFees = 'fees';
  static const String _payloadEvents = 'events';
  static const String _payloadTodayEvents = 'today_events';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  int _nextNotificationId = _updatesNotificationId;
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _pendingPayload;
  Uint8List? _cachedLargeIconBytes;

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
      _notificationSmallIcon,
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
    final normalizedTitle = _sanitizeText(title);
    final normalizedBody = _sanitizeText(body);

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
    final visualSpec = _notificationVisualSpecForTarget(target);
    final displayTitle = _resolveDisplayTitle(normalizedTitle, visualSpec);
    final displayBody = _resolveDisplayBody(normalizedBody, visualSpec);
    final largeIcon = await _loadLargeIconFromAssets();
    final styleLines = <String>[displayBody, visualSpec.openHint];

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        color: visualSpec.accentColor,
        colorized: true,
        styleInformation: InboxStyleInformation(
          styleLines,
          contentTitle: displayTitle,
          summaryText: '$_appLabel • ${visualSpec.summaryText}',
        ),
        icon: _notificationSmallIcon,
        largeIcon: largeIcon,
        subText: visualSpec.summaryText,
        ticker: '$_appLabel ${visualSpec.summaryText}',
        groupKey: _updatesGroupKey,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.reminder,
      ),
    );

    await _plugin.show(
      _nextNotificationId++,
      displayTitle,
      displayBody,
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

  _NotificationVisualSpec _notificationVisualSpecForTarget(
    NotificationNavigationTarget target,
  ) {
    if (target == NotificationNavigationTarget.payments) {
      return const _NotificationVisualSpec(
        accentColor: _brandGold,
        summaryText: 'Payments',
        openHint: 'Tap to open Payments.',
      );
    }

    if (target == NotificationNavigationTarget.todayEvents) {
      return const _NotificationVisualSpec(
        accentColor: _brandBlue,
        summaryText: 'Today\'s Events',
        openHint: 'Tap to open Today\'s Events.',
      );
    }

    return const _NotificationVisualSpec(
      accentColor: _brandBlue,
      summaryText: 'Events',
      openHint: 'Tap to open Events.',
    );
  }

  Future<AndroidBitmap<Object>?> _loadLargeIconFromAssets() async {
    final cachedBytes = _cachedLargeIconBytes;
    if (cachedBytes != null) {
      return ByteArrayAndroidBitmap(cachedBytes);
    }

    try {
      final byteData = await rootBundle.load(_notificationLargeLogoAsset);
      final bytes = byteData.buffer.asUint8List();
      _cachedLargeIconBytes = bytes;
      return ByteArrayAndroidBitmap(bytes);
    } catch (_) {
      return null;
    }
  }

  String _sanitizeText(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final withoutHtmlTags = trimmed.replaceAll(RegExp(r'<[^>]*>'), ' ');
    return withoutHtmlTags.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _resolveDisplayTitle(
    String title,
    _NotificationVisualSpec visualSpec,
  ) {
    if (title.isEmpty) {
      return '${visualSpec.summaryText} Update';
    }

    final normalizedTitle = title.toLowerCase();
    final normalizedSummary = visualSpec.summaryText.toLowerCase();
    if (normalizedTitle == normalizedSummary ||
        normalizedTitle == '$normalizedSummary update') {
      return '${visualSpec.summaryText} Update';
    }

    return title;
  }

  String _resolveDisplayBody(String body, _NotificationVisualSpec visualSpec) {
    if (body.isEmpty) {
      return visualSpec.openHint;
    }

    return body;
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

class _NotificationVisualSpec {
  const _NotificationVisualSpec({
    required this.accentColor,
    required this.summaryText,
    required this.openHint,
  });

  final Color accentColor;
  final String summaryText;
  final String openHint;
}
