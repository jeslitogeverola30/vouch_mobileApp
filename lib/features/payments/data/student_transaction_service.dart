import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';

class StudentTransactionRecord {
  final int id;
  final String studentId;
  final int requirementId;
  final String referenceNumber;
  final String proofPhotoUrl;
  final String status;
  final int? reviewedBy;
  final String reviewNote;

  const StudentTransactionRecord({
    required this.id,
    required this.studentId,
    required this.requirementId,
    required this.referenceNumber,
    required this.proofPhotoUrl,
    required this.status,
    required this.reviewedBy,
    required this.reviewNote,
  });

  factory StudentTransactionRecord.fromMap(Map<String, dynamic> data) {
    return StudentTransactionRecord(
      id: _readInt(data['id']),
      studentId: _readString(data['student_id']),
      requirementId: _readInt(data['requirement_id']),
      referenceNumber: _readString(data['reference_number']),
      proofPhotoUrl: _readString(data['proof_photo_url']),
      status: _readString(data['status']),
      reviewedBy: _readNullableInt(data['reviewed_by']),
      reviewNote: _readRejectionNote(data),
    );
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

  static int? _readNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    if (value is num) {
      return value.toInt();
    }

    return null;
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String _readRejectionNote(Map<String, dynamic> data) {
    final rejectionNote = _readString(data['rejection_note']);
    if (rejectionNote.isNotEmpty) {
      return rejectionNote;
    }

    return _readString(data['review_note']);
  }
}

class StudentTransactionService {
  StudentTransactionService._();

  static final StudentTransactionService instance =
      StudentTransactionService._();

  static const String _transactionsTable = 'student_transactions';
  static const String _studentsTable = 'students';

  final SupabaseClient _client = Supabase.instance.client;

  Future<String> resolveCurrentStudentId() {
    return _resolveCurrentStudentId();
  }

  Future<List<StudentTransactionRecord>>
  fetchTransactionsForCurrentStudent() async {
    final studentId = await _resolveCurrentStudentId();

    dynamic response;
    try {
      response = await _client
          .from(_transactionsTable)
          .select(
            'id, student_id, requirement_id, reference_number, proof_photo_url, status, reviewed_by, rejection_note',
          )
          .eq('student_id', studentId)
          .order('id', ascending: false);
    } on PostgrestException catch (error) {
      if (!_isMissingColumnError(error, 'rejection_note')) {
        rethrow;
      }

      response = await _client
          .from(_transactionsTable)
          .select(
            'id, student_id, requirement_id, reference_number, proof_photo_url, status, reviewed_by',
          )
          .eq('student_id', studentId)
          .order('id', ascending: false);
    }

    return List<Map<String, dynamic>>.from(response)
        .map(StudentTransactionRecord.fromMap)
        .where((record) => record.studentId.trim() == studentId)
        .toList();
  }

  Future<bool> hasSubmissionForRequirement({required int requirementId}) async {
    if (requirementId <= 0) {
      return false;
    }

    final studentId = await _resolveCurrentStudentId();

    final existing = await _client
        .from(_transactionsTable)
        .select('id, status')
        .eq('student_id', studentId)
        .eq('requirement_id', requirementId)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing == null) {
      return false;
    }

    return !_isRejectedStatus(_readString(existing['status']));
  }

  Future<int> createTransaction({
    required int requirementId,
    required String referenceNumber,
    required String proofPhotoUrl,
  }) async {
    final normalizedReference = referenceNumber.trim();
    final normalizedProofUrl = proofPhotoUrl.trim();

    if (requirementId <= 0) {
      throw ArgumentError('Invalid requirement selected.');
    }

    if (normalizedReference.isEmpty) {
      throw ArgumentError('Reference number is required.');
    }

    if (normalizedProofUrl.isEmpty) {
      throw ArgumentError('Proof photo URL is required.');
    }

    final studentId = await _resolveCurrentStudentId();

    final existing = await _client
        .from(_transactionsTable)
        .select('id, status')
        .eq('student_id', studentId)
        .eq('requirement_id', requirementId)
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      final existingStatus = _readString(existing['status']);
      final existingId = _readInt(existing['id']);

      if (!_isRejectedStatus(existingStatus)) {
        throw StateError('You already submitted proof for this fee.');
      }

      if (existingId <= 0) {
        throw StateError('Unable to update previous submission record.');
      }

      Map<String, dynamic>? updated;

      try {
        updated = await _client
            .from(_transactionsTable)
            .update({
              'reference_number': normalizedReference,
              'proof_photo_url': normalizedProofUrl,
              'status': 'pending',
              'reviewed_by': null,
              'rejection_note': null,
            })
            .eq('id', existingId)
            .eq('student_id', studentId)
            .select('id')
            .maybeSingle();
      } on PostgrestException catch (error) {
        if (!_isMissingColumnError(error, 'rejection_note')) {
          rethrow;
        }

        updated = await _client
            .from(_transactionsTable)
            .update({
              'reference_number': normalizedReference,
              'proof_photo_url': normalizedProofUrl,
              'status': 'pending',
              'reviewed_by': null,
            })
            .eq('id', existingId)
            .eq('student_id', studentId)
            .select('id')
            .maybeSingle();
      }

      final updatedId = _readInt(updated?['id']);
      if (updatedId > 0) {
        return updatedId;
      }

      throw StateError('Unable to update previous submission record.');
    }

    try {
      final response = await _client
          .from(_transactionsTable)
          .insert({
            'student_id': studentId,
            'requirement_id': requirementId,
            'reference_number': normalizedReference,
            'proof_photo_url': normalizedProofUrl,
            'status': 'pending',
          })
          .select('id')
          .single();

      final insertedId = response['id'];
      final parsedInsertedId = _readInt(insertedId);
      if (parsedInsertedId > 0) {
        return parsedInsertedId;
      }

      throw StateError('Transaction was created but no valid id was returned.');
    } on PostgrestException catch (error) {
      if (_isGlobalRequirementDuplicate(error)) {
        throw StateError(
          'Submissions are currently limited by a database rule. Update student_transactions so (student_id, requirement_id) is unique instead of requirement_id alone.',
        );
      }

      rethrow;
    }
  }

  Future<String> _resolveCurrentStudentId() async {
    final user = SupabaseAuthService.currentUser;
    if (user == null) {
      throw StateError('No authenticated student found.');
    }

    final normalizedEmail = _normalizeEmail(user.email);
    final metadataStudentId = _readString(user.userMetadata?['student_id']);

    final metadataRow = await _fetchStudentById(metadataStudentId);
    if (_isMatchingStudentRow(metadataRow, normalizedEmail: normalizedEmail)) {
      return _readString(metadataRow?['student_id']);
    }

    final authUserId = _readString(user.id);
    final authIdRow = await _fetchStudentById(authUserId);
    if (_isMatchingStudentRow(authIdRow, normalizedEmail: normalizedEmail)) {
      return _readString(authIdRow?['student_id']);
    }

    if (normalizedEmail.isEmpty) {
      throw StateError('No authenticated student found.');
    }

    final exactEmailRow = await _fetchStudentByEmail(normalizedEmail);
    final exactEmailStudentId = _readString(exactEmailRow?['student_id']);
    if (exactEmailStudentId.isNotEmpty) {
      return exactEmailStudentId;
    }

    final student = await _client
        .from(_studentsTable)
        .select('student_id, email')
        .ilike('email', normalizedEmail)
        .maybeSingle();

    final studentId = student?['student_id']?.toString().trim() ?? '';
    if (studentId.isNotEmpty) {
      return studentId;
    }

    throw StateError('Student account not found.');
  }

  Future<Map<String, dynamic>?> _fetchStudentById(String studentId) async {
    final normalizedStudentId = studentId.trim();
    if (normalizedStudentId.isEmpty) {
      return null;
    }

    return _client
        .from(_studentsTable)
        .select('student_id, email')
        .eq('student_id', normalizedStudentId)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> _fetchStudentByEmail(String email) async {
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) {
      return null;
    }

    return _client
        .from(_studentsTable)
        .select('student_id, email')
        .eq('email', normalizedEmail)
        .maybeSingle();
  }

  bool _isMatchingStudentRow(
    Map<String, dynamic>? row, {
    required String normalizedEmail,
  }) {
    final studentId = _readString(row?['student_id']);
    if (studentId.isEmpty) {
      return false;
    }

    if (normalizedEmail.isEmpty) {
      return true;
    }

    final rowEmail = _normalizeEmail(row?['email']);
    return rowEmail.isEmpty || rowEmail == normalizedEmail;
  }

  String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  int _readInt(dynamic value) {
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

  String _normalizeEmail(dynamic rawEmail) {
    final email = rawEmail?.toString().trim().toLowerCase() ?? '';
    return email;
  }

  bool _isRejectedStatus(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase();
    return normalized == 'rejected' || normalized == 'declined';
  }

  bool _isMissingColumnError(PostgrestException error, String columnName) {
    final details = '${error.details ?? ''}'.toLowerCase();
    final hint = (error.hint ?? '').toLowerCase();
    final message = error.message.toLowerCase();
    final lookup = columnName.trim().toLowerCase();
    final combined = '$message $details $hint';

    return combined.contains('column') && combined.contains(lookup);
  }

  bool _isGlobalRequirementDuplicate(PostgrestException error) {
    if (error.code?.trim() != '23505') {
      return false;
    }

    final normalized =
        '${error.message} ${error.details ?? ''} ${error.hint ?? ''}'
            .toLowerCase();

    return normalized.contains('requirement_id') &&
        (normalized.contains('duplicate') || normalized.contains('unique'));
  }
}
