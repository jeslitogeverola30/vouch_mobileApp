class EventAttendanceStatus {
  EventAttendanceStatus._();

  static const String present = 'PRESENT';
  static const String absent = 'ABSENT';
}

class StudentAttendance {
  final String id;
  final String name;
  final String program;
  final String? timeIn;
  final String? timeOut;
  final String status;
  final String avatarUrl;

  const StudentAttendance({
    required this.id,
    required this.name,
    required this.program,
    this.timeIn,
    this.timeOut,
    required this.status,
    required this.avatarUrl,
  });
}

class EventAttendanceDomain {
  EventAttendanceDomain._();

  static List<StudentAttendance> filterStudents(
    List<StudentAttendance> students,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return students;
    }

    return students
        .where(
          (student) =>
              student.name.toLowerCase().contains(normalizedQuery) ||
              student.id.contains(normalizedQuery),
        )
        .toList();
  }
}
