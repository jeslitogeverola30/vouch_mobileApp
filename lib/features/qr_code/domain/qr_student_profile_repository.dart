import 'qr_student_profile_entity.dart';

abstract class QrStudentProfileRepository {
  Future<QrStudentProfileEntity?> getCurrentStudentProfile();
}
