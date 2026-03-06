class ProfileEntity {
  const ProfileEntity({
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.faculty,
    required this.program,
    this.createdAt,
    this.profilePhotoUrl = '',
    this.accountStatus = '',
  });

  final String email;
  final String fullName;
  final String studentId;
  final String faculty;
  final String program;
  final DateTime? createdAt;
  final String profilePhotoUrl;
  final String accountStatus;

  factory ProfileEntity.fromMap(Map<String, dynamic> data) {
    return ProfileEntity(
      email: _readString(data['email']),
      fullName: _readString(data['full_name']),
      studentId: _readString(data['student_id']),
      faculty: _readString(data['faculty']),
      program: _readString(data['program']),
      createdAt: _parseDateTime(data['created_at']),
      profilePhotoUrl: _readString(data['profile_photo_url']),
      accountStatus: _readString(data['account_status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'full_name': fullName,
      'student_id': studentId,
      'faculty': faculty,
      'program': program,
      'created_at': createdAt?.toIso8601String(),
      'profile_photo_url': profilePhotoUrl,
      'account_status': accountStatus,
    };
  }

  static String _readString(dynamic value) {
    if (value is! String) {
      return '';
    }

    return value.trim();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}
