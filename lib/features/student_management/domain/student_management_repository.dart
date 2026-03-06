import 'attendance_record_entity.dart';
import 'student_entity.dart';

abstract class StudentManagementRepository {
  Future<List<StudentEntity>> fetchStudents();

  Future<List<AttendanceRecordEntity>> fetchAttendanceRecords();

  Future<void> freezeStudents(List<String> studentIds);

  Future<void> activateStudents(List<String> studentIds);

  Future<void> deleteStudents(List<String> studentIds);
}
