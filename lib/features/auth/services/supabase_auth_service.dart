import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService._();

  static final GoTrueClient _auth = Supabase.instance.client.auth;

  static User? get currentUser => _auth.currentUser;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? studentId,
    String? faculty,
    String? program,
    String? firstName,
    String? lastName,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
        if (studentId != null && studentId.isNotEmpty) 'student_id': studentId,
        if (faculty != null && faculty.isNotEmpty) 'faculty': faculty,
        if (program != null && program.isNotEmpty) 'program': program,
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      },
      emailRedirectTo: null,
    );
  }

  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> sendSignInOtp({required String email}) {
    return _auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
      emailRedirectTo: null,
    );
  }

  static Future<AuthResponse> verifySignUpOtp({
    required String email,
    required String code,
  }) {
    return _auth.verifyOTP(email: email, token: code, type: OtpType.signup);
  }

  static Future<AuthResponse> verifySignInOtp({
    required String email,
    required String code,
  }) {
    return _auth.verifyOTP(email: email, token: code, type: OtpType.email);
  }

  static Future<void> resendSignUpOtp({required String email}) {
    return _auth.resend(type: OtpType.signup, email: email);
  }

  static Future<void> resendSignInOtp({required String email}) {
    return _auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
      emailRedirectTo: null,
    );
  }

  static Future<void> sendPasswordRecoveryOtp({required String email}) {
    return _auth.resetPasswordForEmail(email, redirectTo: null);
  }

  static Future<AuthResponse> verifyPasswordRecoveryOtp({
    required String email,
    required String code,
  }) {
    return _auth.verifyOTP(email: email, token: code, type: OtpType.recovery);
  }

  static Future<UserResponse> requestEmailChange({required String newEmail}) {
    return _auth.updateUser(UserAttributes(email: newEmail));
  }

  static Future<AuthResponse> verifyEmailChangeOtp({
    required String email,
    required String code,
  }) {
    return _auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.emailChange,
    );
  }

  static Future<void> resendEmailChangeOtp({required String email}) {
    return _auth.resend(type: OtpType.emailChange, email: email);
  }

  static Future<UserResponse> updatePassword({required String newPassword}) {
    return _auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> signOut() {
    return _auth.signOut();
  }

  static Future<String> determineUserRole() async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user found');
    }

    final email = user.email!;

    // 1. Check admins table first (priority)
    final adminCheck = await Supabase.instance.client
        .from('admins')
        .select('id')
        .ilike('email', email)
        .maybeSingle();

    if (adminCheck != null) return 'admin';

    // 2. Then check students table
    final studentCheck = await Supabase.instance.client
        .from('students')
        .select('student_id')
        .ilike('email', email)
        .maybeSingle();

    if (studentCheck != null) return 'student';

    throw Exception('User role could not be determined');
  }
}
