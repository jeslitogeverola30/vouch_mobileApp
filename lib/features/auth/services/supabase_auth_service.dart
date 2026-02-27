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

  static Future<void> signOut() {
    return _auth.signOut();
  }
}
