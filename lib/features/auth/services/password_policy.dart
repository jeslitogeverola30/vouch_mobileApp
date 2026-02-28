class PasswordPolicy {
  PasswordPolicy._();

  static const String requirementMessage =
      'Password must be 12 to 16 characters and include uppercase, lowercase, number, and symbol.';

  static bool isValid(String password) {
    if (password.length < 12 || password.length > 16) {
      return false;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(password);

    return hasUppercase && hasLowercase && hasNumber && hasSymbol;
  }
}
