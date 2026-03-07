import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import 'payment_receiver_service.dart';

class PaymentRequirementDetails {
  final int id;
  final String title;
  final String description;
  final double amount;
  final String receiverGcash;
  final String receiverName;
  final bool isMandatory;
  final int adminId;

  const PaymentRequirementDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.receiverGcash,
    required this.receiverName,
    required this.isMandatory,
    required this.adminId,
  });

  factory PaymentRequirementDetails.fromMap(Map<String, dynamic> data) {
    return PaymentRequirementDetails(
      id: _readInt(data['id']),
      title: _readString(data['title']),
      description: _readString(data['description']),
      amount: _readDouble(data['amount']),
      receiverGcash: _readString(data['receiver_gcash']),
      receiverName: _readString(data['receiver_name']),
      isMandatory: _readBool(data['is_mandatory']),
      adminId: _readInt(data['admin_id']),
    );
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }

    return 0;
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

class PaymentRequirementService {
  PaymentRequirementService._();

  static final PaymentRequirementService instance =
      PaymentRequirementService._();

  static const String _tableName = 'payment_requirements';
  static const String _academicTermsTable = 'academic_terms';

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PaymentRequirementDetails>> fetchRequirementsForStudents() async {
    final response = await _client
        .from(_tableName)
        .select(
          'id, title, description, amount, receiver_gcash, receiver_name, is_mandatory, admin_id',
        )
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(PaymentRequirementDetails.fromMap).toList();
  }

  Future<List<PaymentRequirementDetails>>
  fetchRequirementsForCurrentAdmin() async {
    final adminId = await _resolveCurrentAdminId();

    final response = await _client
        .from(_tableName)
        .select(
          'id, title, description, amount, receiver_gcash, receiver_name, is_mandatory, admin_id',
        )
        .eq('admin_id', adminId)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(PaymentRequirementDetails.fromMap).toList();
  }

  Future<int> createRequirement({
    required String title,
    required String description,
    required double amount,
    required bool isMandatory,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();

    if (normalizedTitle.isEmpty) {
      throw ArgumentError('Fee title is required.');
    }

    if (amount <= 0) {
      throw ArgumentError('Fee amount must be greater than zero.');
    }

    final receiver = await PaymentReceiverService.instance
        .fetchActiveReceiver();
    if (receiver == null) {
      throw StateError(
        'No active receiver found. Please set receiver details first.',
      );
    }

    final receiverName = receiver.name.trim();
    final receiverGcashDigits = receiver.gcashNumber.replaceAll(
      RegExp(r'\D'),
      '',
    );
    if (receiverName.isEmpty || receiverGcashDigits.isEmpty) {
      throw StateError(
        'Receiver details are incomplete. Please update receiver details first.',
      );
    }

    final adminId = await _resolveCurrentAdminId();
    final termId = await _resolveActiveTermId();

    final response = await _client
        .from(_tableName)
        .insert({
          'term_id': termId,
          'title': normalizedTitle,
          'description': normalizedDescription.isNotEmpty
              ? normalizedDescription
              : 'No additional instructions.',
          'amount': amount,
          'receiver_gcash': receiverGcashDigits,
          'receiver_name': receiverName,
          'is_mandatory': isMandatory,
          'admin_id': adminId,
        })
        .select('id')
        .single();

    final insertedId = response['id'];

    if (insertedId is int) {
      return insertedId;
    }

    if (insertedId is String) {
      final parsed = int.tryParse(insertedId.trim());
      if (parsed != null) {
        return parsed;
      }
    }

    throw StateError('Fee was created but no valid id was returned.');
  }

  Future<int> _resolveCurrentAdminId() async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      throw StateError('No authenticated admin found.');
    }

    final admin = await _client
        .from('admins')
        .select('id')
        .ilike('email', email)
        .maybeSingle();

    final adminId = admin?['id'];
    if (adminId is int) {
      return adminId;
    }

    if (adminId is String) {
      final parsed = int.tryParse(adminId.trim());
      if (parsed != null) {
        return parsed;
      }
    }

    throw StateError('Admin account not found.');
  }

  Future<int> _resolveActiveTermId() async {
    final activeTerm = await _client
        .from(_academicTermsTable)
        .select('id')
        .eq('is_active', true)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    final activeTermId = _readInt(activeTerm?['id']);
    if (activeTermId > 0) {
      return activeTermId;
    }

    final fallbackTerm = await _client
        .from(_academicTermsTable)
        .select('id')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    final fallbackTermId = _readInt(fallbackTerm?['id']);
    if (fallbackTermId > 0) {
      return fallbackTermId;
    }

    throw StateError(
      'No academic term found. Please add an academic term first.',
    );
  }

  int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }
}
