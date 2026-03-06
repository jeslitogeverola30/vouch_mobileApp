import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentReceiverDetails {
  final String id;
  final String name;
  final String gcashNumber;
  final String position;
  final bool isActive;

  const PaymentReceiverDetails({
    required this.id,
    required this.name,
    required this.gcashNumber,
    required this.position,
    required this.isActive,
  });

  factory PaymentReceiverDetails.fromMap(Map<String, dynamic> data) {
    return PaymentReceiverDetails(
      id: _readString(data['receiver_id']),
      name: _readString(data['receiver_name']),
      gcashNumber: _readString(data['receiver_gcash']),
      position: _readString(data['receiver_position']),
      isActive: _readBool(data['is_active']),
    );
  }

  static String formatGcashNumber(String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) {
      return rawValue.trim();
    }

    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 't';
  }
}

class PaymentReceiverService {
  PaymentReceiverService._();

  static final PaymentReceiverService instance = PaymentReceiverService._();

  static const String tableName = 'payment_receiver';
  static const String defaultReceiverId = 'main_receiver';

  final SupabaseClient _client = Supabase.instance.client;

  Future<PaymentReceiverDetails?> fetchActiveReceiver() async {
    final response = await _client
        .from(tableName)
        .select(
          'receiver_id, receiver_name, receiver_gcash, receiver_position, is_active',
        )
        .eq('is_active', true)
        .order('receiver_id', ascending: true)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return PaymentReceiverDetails.fromMap(response);
  }

  Future<PaymentReceiverDetails> upsertReceiver({
    required String name,
    required String gcashNumber,
    required String position,
    String receiverId = defaultReceiverId,
    bool isActive = true,
  }) async {
    final normalizedReceiverId = receiverId.trim().isEmpty
        ? defaultReceiverId
        : receiverId.trim();

    final response = await _client
        .from(tableName)
        .upsert({
          'receiver_id': normalizedReceiverId,
          'receiver_name': name.trim(),
          'receiver_gcash': gcashNumber.trim(),
          'receiver_position': position.trim(),
          'is_active': isActive,
        }, onConflict: 'receiver_id')
        .select(
          'receiver_id, receiver_name, receiver_gcash, receiver_position, is_active',
        )
        .single();

    return PaymentReceiverDetails.fromMap(response);
  }
}
