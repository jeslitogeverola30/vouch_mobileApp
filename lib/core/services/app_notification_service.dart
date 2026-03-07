import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/supabase_auth_service.dart';

class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  static const String _eventsTable = 'events';
  static const String _paymentRequirementsTable = 'payment_requirements';
  static const String _enabledKey = 'notifications_enabled';
  static const String _lastSeenEventIdPrefix = 'last_seen_event_id';
  static const String _lastSeenFeeIdPrefix = 'last_seen_fee_id';
  static const String _lastTodaySignaturePrefix = 'last_today_events_signature';
  static const Duration _checkInterval = Duration(seconds: 20);

  final SupabaseClient _client = Supabase.instance.client;
  final ValueNotifier<bool> isEnabledListenable = ValueNotifier<bool>(true);

  SharedPreferences? _preferences;
  bool _isInitialized = false;
  bool _isChecking = false;
  DateTime? _lastCheckedAt;

  bool get isEnabled => isEnabledListenable.value;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();
    isEnabledListenable.value = _preferences?.getBool(_enabledKey) ?? true;
    _isInitialized = true;
  }

  Future<bool> toggleEnabled() async {
    await initialize();
    final nextValue = !isEnabledListenable.value;
    await _setEnabled(nextValue);
    return nextValue;
  }

  Future<List<String>> checkForUpdates({bool force = false}) async {
    await initialize();

    if (!isEnabledListenable.value) {
      return const <String>[];
    }

    if (_isChecking) {
      return const <String>[];
    }

    final now = DateTime.now();
    if (!force &&
        _lastCheckedAt != null &&
        now.difference(_lastCheckedAt!) < _checkInterval) {
      return const <String>[];
    }

    final email = _normalizedCurrentEmail();
    if (email == null) {
      _lastCheckedAt = now;
      return const <String>[];
    }

    _isChecking = true;

    try {
      final snapshot = await _fetchSnapshot();
      final keys = _PreferenceKeys.forEmail(email);
      final preferences = _preferences;

      if (preferences == null) {
        return const <String>[];
      }

      final previousEventId = preferences.getInt(keys.lastSeenEventIdKey);
      final previousFeeId = preferences.getInt(keys.lastSeenFeeIdKey);
      final previousTodaySignature = preferences.getString(
        keys.lastTodaySignatureKey,
      );

      final hasBaseline =
          previousEventId != null ||
          previousFeeId != null ||
          previousTodaySignature != null;

      final messages = <String>[];

      if (hasBaseline) {
        if (previousEventId != null) {
          final newEventCount = snapshot.eventIds.where((id) {
            return id > previousEventId;
          }).length;

          if (newEventCount > 0) {
            messages.add(
              newEventCount == 1
                  ? 'New event available.'
                  : '$newEventCount new events available.',
            );
          }
        }

        if (previousFeeId != null) {
          final newFeeCount = snapshot.feeIds.where((id) {
            return id > previousFeeId;
          }).length;

          if (newFeeCount > 0) {
            messages.add(
              newFeeCount == 1
                  ? 'New fee posted.'
                  : '$newFeeCount new fees posted.',
            );
          }
        }

        if (snapshot.todayEventsSignature.isNotEmpty &&
            snapshot.todayEventsSignature != previousTodaySignature) {
          final todayCount = snapshot.todayEventIds.length;
          if (todayCount > 0) {
            messages.add(
              todayCount == 1
                  ? 'You have 1 event scheduled today.'
                  : 'You have $todayCount events scheduled today.',
            );
          }
        }
      }

      await preferences.setInt(keys.lastSeenEventIdKey, snapshot.latestEventId);
      await preferences.setInt(keys.lastSeenFeeIdKey, snapshot.latestFeeId);
      await preferences.setString(
        keys.lastTodaySignatureKey,
        snapshot.todayEventsSignature,
      );

      _lastCheckedAt = now;
      return messages;
    } catch (_) {
      _lastCheckedAt = now;
      return const <String>[];
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _setEnabled(bool enabled) async {
    final preferences = _preferences;
    if (preferences != null) {
      await preferences.setBool(_enabledKey, enabled);
    }

    isEnabledListenable.value = enabled;
  }

  Future<_NotificationSnapshot> _fetchSnapshot() async {
    final eventRows = List<Map<String, dynamic>>.from(
      await _client.from(_eventsTable).select('id, event_date'),
    );

    final feeRows = List<Map<String, dynamic>>.from(
      await _client.from(_paymentRequirementsTable).select('id'),
    );

    final eventIds = eventRows
        .map((row) => _readInt(row['id']))
        .whereType<int>()
        .toList(growable: false);

    final feeIds = feeRows
        .map((row) => _readInt(row['id']))
        .whereType<int>()
        .toList(growable: false);

    final latestEventId = eventIds.isEmpty
        ? 0
        : eventIds.reduce((left, right) => left > right ? left : right);
    final latestFeeId = feeIds.isEmpty
        ? 0
        : feeIds.reduce((left, right) => left > right ? left : right);

    final today = _dateOnly(DateTime.now());
    final todayEventIds =
        eventRows
            .where((row) {
              final eventDate = _parseDate(row['event_date']);
              if (eventDate == null) {
                return false;
              }
              return eventDate.isAtSameMomentAs(today);
            })
            .map((row) => _readInt(row['id']))
            .whereType<int>()
            .toList(growable: false)
          ..sort();

    final todaySignature = _buildTodaySignature(today, todayEventIds);

    return _NotificationSnapshot(
      eventIds: eventIds,
      feeIds: feeIds,
      latestEventId: latestEventId,
      latestFeeId: latestFeeId,
      todayEventIds: todayEventIds,
      todayEventsSignature: todaySignature,
    );
  }

  String _buildTodaySignature(DateTime today, List<int> todayEventIds) {
    final dateKey =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (todayEventIds.isEmpty) {
      return '$dateKey|';
    }

    return '$dateKey|${todayEventIds.join(',')}';
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return _dateOnly(value.toLocal());
    }

    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return null;
    }

    return _dateOnly(parsed.toLocal());
  }

  String? _normalizedCurrentEmail() {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return null;
    }

    return email.toLowerCase();
  }

  int? _readInt(dynamic value) {
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

class _PreferenceKeys {
  const _PreferenceKeys({
    required this.lastSeenEventIdKey,
    required this.lastSeenFeeIdKey,
    required this.lastTodaySignatureKey,
  });

  final String lastSeenEventIdKey;
  final String lastSeenFeeIdKey;
  final String lastTodaySignatureKey;

  factory _PreferenceKeys.forEmail(String email) {
    final normalized = email.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '_',
    );

    return _PreferenceKeys(
      lastSeenEventIdKey:
          '${AppNotificationService._lastSeenEventIdPrefix}_$normalized',
      lastSeenFeeIdKey:
          '${AppNotificationService._lastSeenFeeIdPrefix}_$normalized',
      lastTodaySignatureKey:
          '${AppNotificationService._lastTodaySignaturePrefix}_$normalized',
    );
  }
}

class _NotificationSnapshot {
  const _NotificationSnapshot({
    required this.eventIds,
    required this.feeIds,
    required this.latestEventId,
    required this.latestFeeId,
    required this.todayEventIds,
    required this.todayEventsSignature,
  });

  final List<int> eventIds;
  final List<int> feeIds;
  final int latestEventId;
  final int latestFeeId;
  final List<int> todayEventIds;
  final String todayEventsSignature;
}
