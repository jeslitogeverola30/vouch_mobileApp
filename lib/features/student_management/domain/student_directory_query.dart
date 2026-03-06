import 'student_entity.dart';

class StudentDirectoryQuery {
  const StudentDirectoryQuery._();

  static List<StudentEntity> filterStudents({
    required List<StudentEntity> students,
    required String query,
    required String selectedStatus,
    required String selectedProgram,
    required String allProgramsLabel,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return students.where((student) {
      final matchesSearch =
          normalizedQuery.isEmpty ||
          student.name.toLowerCase().contains(normalizedQuery) ||
          student.studentId.toLowerCase().contains(normalizedQuery) ||
          student.program.toLowerCase().contains(normalizedQuery);

      final matchesStatus =
          selectedStatus == 'All' || student.status == selectedStatus;
      final matchesProgram =
          selectedProgram == allProgramsLabel ||
          student.program == selectedProgram;

      return matchesSearch && matchesStatus && matchesProgram;
    }).toList();
  }

  static int countByStatus(List<StudentEntity> students, String status) {
    if (status == 'All') {
      return students.length;
    }

    return students.where((student) => student.status == status).length;
  }
}
