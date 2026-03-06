import '../domain/attendance_record_entity.dart';
import '../domain/student_entity.dart';
import '../domain/student_management_repository.dart';

class MockStudentManagementImpl implements StudentManagementRepository {
  const MockStudentManagementImpl._();

  static const MockStudentManagementImpl instance =
      MockStudentManagementImpl._();

  static const List<StudentEntity> seedStudents = [
    StudentEntity(
      name: 'Jeslito G. Geverola',
      program: 'BS Information Technology',
      studentId: '2023-0222',
      email: 'jeslito.geverola@dorsu.edu.ph',
      status: 'Active',
      initials: 'JG',
    ),
    StudentEntity(
      name: 'Maria Santos',
      program: 'BS Computer Science',
      studentId: '2022-0115',
      email: 'maria.santos@dorsu.edu.ph',
      status: 'Pending',
      initials: 'MS',
    ),
    StudentEntity(
      name: 'Juan Dela Cruz',
      program: 'BSED - Mathematics',
      studentId: '2021-1089',
      email: 'juan.delacruz@dorsu.edu.ph',
      status: 'Frozen',
      initials: 'JD',
    ),
    StudentEntity(
      name: 'Anna Reyes',
      program: 'BS Information Technology',
      studentId: '2024-0301',
      email: 'anna.reyes@dorsu.edu.ph',
      status: 'Active',
      initials: 'AR',
    ),
    StudentEntity(
      name: 'Paolo Ramirez',
      program: 'BS Information Technology',
      studentId: '2020-0420',
      email: 'paolo.ramirez@dorsu.edu.ph',
      status: 'Pending',
      initials: 'PR',
    ),
    StudentEntity(
      name: 'Lara Velasco',
      program: 'BS Accountancy',
      studentId: '2023-0550',
      email: 'lara.velasco@dorsu.edu.ph',
      status: 'Frozen',
      initials: 'LV',
    ),
  ];

  @override
  Future<List<StudentEntity>> fetchStudents() async {
    return seedStudents;
  }

  @override
  Future<List<AttendanceRecordEntity>> fetchAttendanceRecords() async {
    return const [];
  }

  @override
  Future<void> freezeStudents(List<String> studentIds) async {}

  @override
  Future<void> activateStudents(List<String> studentIds) async {}

  @override
  Future<void> deleteStudents(List<String> studentIds) async {}
}
