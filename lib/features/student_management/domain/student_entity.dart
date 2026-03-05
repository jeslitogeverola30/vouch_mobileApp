class StudentEntity {
  const StudentEntity({
    required this.name,
    required this.program,
    required this.studentId,
    required this.email,
    required this.status,
    required this.initials,
  });

  final String name;
  final String program;
  final String studentId;
  final String email;
  final String status;
  final String initials;
}
