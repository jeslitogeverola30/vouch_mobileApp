import '../../profile/data/supabase_profile_repository_impl.dart';
import '../domain/qr_student_profile_entity.dart';
import '../domain/qr_student_profile_repository.dart';

class QrStudentProfileRepositoryImpl implements QrStudentProfileRepository {
  QrStudentProfileRepositoryImpl._();

  static final QrStudentProfileRepositoryImpl instance =
      QrStudentProfileRepositoryImpl._();

  @override
  Future<QrStudentProfileEntity?> getCurrentStudentProfile() async {
    final profile = await SupabaseProfileRepositoryImpl.instance
        .getCurrentUserProfile();

    if (profile == null) {
      return null;
    }

    return QrStudentProfileEntity(
      email: profile.email,
      studentId: profile.studentId,
      fullName: profile.fullName,
      faculty: profile.faculty,
      program: profile.program,
      profilePhotoUrl: profile.profilePhotoUrl,
    );
  }
}
