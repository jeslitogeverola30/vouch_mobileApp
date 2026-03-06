class QrStudentProfileEntity {
  const QrStudentProfileEntity({
    required this.email,
    required this.studentId,
    required this.fullName,
    required this.faculty,
    required this.program,
    this.profilePhotoUrl = '',
  });

  final String email;
  final String studentId;
  final String fullName;
  final String faculty;
  final String program;
  final String profilePhotoUrl;
}
