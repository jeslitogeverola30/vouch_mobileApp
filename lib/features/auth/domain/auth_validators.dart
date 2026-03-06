class AuthValidators {
  AuthValidators._();

  static final RegExp _otpRegex = RegExp(r'^\d{8}$');
  static final RegExp _schoolIdRegex = RegExp(r'^\d{4}-\d{4}$');
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static bool isOtpCode(String code) {
    return _otpRegex.hasMatch(code.trim());
  }

  static bool isSchoolId(String schoolId) {
    return _schoolIdRegex.hasMatch(schoolId.trim());
  }

  static bool isEmailAddress(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  static bool isDifferentPassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return currentPassword != newPassword;
  }

  static bool requiresSignInVerification(String errorMessage) {
    final normalized = errorMessage.toLowerCase();

    return normalized.contains('email not confirmed') ||
        normalized.contains('email_not_confirmed');
  }

  static ({String? firstName, String? lastName}) splitFullName(
    String fullName,
  ) {
    final names = fullName.split(' ').where((part) => part.isNotEmpty).toList();

    return (
      firstName: names.isNotEmpty ? names.first : null,
      lastName: names.length > 1 ? names.sublist(1).join(' ') : null,
    );
  }
}
