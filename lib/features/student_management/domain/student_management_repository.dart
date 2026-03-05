import 'attendance_record_entity.dart';
import 'student_entity.dart';

abstract class StudentManagementRepository {
  Future<List<StudentEntity>> fetchStudents();

  Future<List<AttendanceRecordEntity>> fetchAttendanceRecords();
}
