class QrPayloadEntity {
  const QrPayloadEntity({
    required this.studentId,
    required this.fullName,
    required this.faculty,
    required this.program,
  });

  final String studentId;
  final String fullName;
  final String faculty;
  final String program;

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'full_name': fullName,
      'faculty': faculty,
      'program': program,
    };
  }

  bool get isValid {
    return studentId.trim().isNotEmpty && fullName.trim().isNotEmpty;
  }
}
