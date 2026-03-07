import 'package:supabase_flutter/supabase_flutter.dart';

class AcademicTermOption {
  const AcademicTermOption({
    required this.id,
    required this.academicYear,
    required this.semester,
    required this.isActive,
  });

  final int id;
  final String academicYear;
  final String semester;
  final bool isActive;

  String get label => '$semester • A.Y. $academicYear';

  factory AcademicTermOption.fromMap(Map<String, dynamic> data) {
    return AcademicTermOption(
      id: _readInt(data['id']),
      academicYear: _readString(data['academic_year']),
      semester: _readString(data['semester']),
      isActive: _readBool(data['is_active']),
    );
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static int _readInt(dynamic value) {
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

class AcademicTermService {
  AcademicTermService._();

  static const String _tableName = 'academic_terms';
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<AcademicTermOption>> fetchTerms() async {
    final response = await _client
        .from(_tableName)
        .select('id, academic_year, semester, is_active')
        .order('is_active', ascending: false)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(
      response,
    ).map(AcademicTermOption.fromMap).toList();
  }

  static Future<void> createTerm({
    required String academicYear,
    required String semester,
    bool setActive = false,
  }) async {
    final normalizedYear = academicYear.trim();
    final normalizedSemester = semester.trim();

    if (normalizedYear.isEmpty || normalizedSemester.isEmpty) {
      throw ArgumentError('Academic year and semester are required.');
    }

    await _client.from(_tableName).insert({
      'academic_year': normalizedYear,
      'semester': normalizedSemester,
      'is_active': setActive,
    });
  }

  static Future<void> setActiveTerm({required int termId}) async {
    if (termId <= 0) {
      throw ArgumentError('A valid academic term is required.');
    }

    await _client.from(_tableName).update({'is_active': true}).eq('id', termId);
  }
}
