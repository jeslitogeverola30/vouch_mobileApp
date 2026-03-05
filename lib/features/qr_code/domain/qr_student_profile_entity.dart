class QrStudentProfileEntity {
  const QrStudentProfileEntity({
    required this.studentId,
    required this.fullName,
    required this.faculty,
    required this.program,
  });

  final String studentId;
  final String fullName;
  final String faculty;
  final String program;
}
