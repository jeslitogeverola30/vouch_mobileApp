class StudentEntity {
  const StudentEntity({
    required this.name,
    required this.program,
    required this.studentId,
    required this.email,
    required this.status,
    required this.initials,
    this.avatarUrl = '',
  });

  final String name;
  final String program;
  final String studentId;
  final String email;
  final String status;
  final String initials;
  final String avatarUrl;

  StudentEntity copyWith({
    String? name,
    String? program,
    String? studentId,
    String? email,
    String? status,
    String? initials,
    String? avatarUrl,
  }) {
    return StudentEntity(
      name: name ?? this.name,
      program: program ?? this.program,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      status: status ?? this.status,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
