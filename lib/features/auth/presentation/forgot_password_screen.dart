import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/app_router.dart';
import '../data/auth_profile_sync_service.dart';
import '../domain/auth_validators.dart';
import '../domain/password_policy.dart';
import '../data/supabase_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _isSendingCode = false;
  bool _isSubmitting = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
    _codeController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first.')),
      );
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      await SupabaseAuthService.sendPasswordRecoveryOtp(email: email);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSendingCode = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSendingCode = false;
      _codeSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery code sent to your email.')),
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty ||
        code.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (!AuthValidators.isOtpCode(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 8-digit verification code.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    if (!PasswordPolicy.isValid(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(PasswordPolicy.requirementMessage)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await SupabaseAuthService.verifyPasswordRecoveryOtp(
        email: email,
        code: code,
      );
      await SupabaseAuthService.updatePassword(newPassword: newPassword);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    try {
      await AuthProfileSyncService.ensureCurrentUserProfile();
    } catch (_) {}

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset successful.')));

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.studentHome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Positioned(
                  top: 70,
                  right: -50,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(120),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 170,
                  left: -30,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003DA5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(90),
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboardInset = MediaQuery.of(
                      context,
                    ).viewInsets.bottom;

                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        24,
                        20,
                        keyboardInset > 0 ? keyboardInset + 24 : 24,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(
                                    0xFF003DA5,
                                  ).withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  22,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        icon: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Color(0xFF003DA5),
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/logos/vouch_logo.png',
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 2),
                                        RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            children: const [
                                              TextSpan(
                                                text: 'ou',
                                                style: TextStyle(
                                                  color: Color(0xFF003DA5),
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'ch',
                                                style: TextStyle(
                                                  color: Color(0xFFFFC107),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Forgot password',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF003DA5),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Get an 8-digit code and set your new password',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      controller: _emailController,
                                      hintText: 'Enter your email',
                                      icon: Icons.mail_outline,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: _isSendingCode
                                            ? null
                                            : _sendCode,
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: const Color(
                                              0xFF003DA5,
                                            ).withOpacity(0.35),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: _isSendingCode
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                _codeSent
                                                    ? 'Resend Code'
                                                    : 'Send Code',
                                                style: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF003DA5,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInputField(
                                      controller: _codeController,
                                      hintText: '8-digit code',
                                      icon: Icons.verified_outlined,
                                      keyboardType: TextInputType.number,
                                      maxLength: 8,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      textInputAction: TextInputAction.next,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPasswordField(
                                      controller: _newPasswordController,
                                      hintText: 'New password',
                                      isVisible: _showNewPassword,
                                      onToggle: () {
                                        setState(
                                          () => _showNewPassword =
                                              !_showNewPassword,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPasswordField(
                                      controller: _confirmPasswordController,
                                      hintText: 'Retype new password',
                                      isVisible: _showConfirmPassword,
                                      onToggle: () {
                                        setState(
                                          () => _showConfirmPassword =
                                              !_showConfirmPassword,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isSubmitting
                                            ? null
                                            : _resetPassword,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFFC107,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF003DA5,
                                          ),
                                          disabledBackgroundColor: const Color(
                                            0xFFFFC107,
                                          ).withOpacity(0.6),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFF003DA5)),
                                                ),
                                              )
                                            : Text(
                                                'Reset Password',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textInputAction: textInputAction,
      textAlign: textAlign,
      decoration: _buildInputDecoration(
        hintText: hintText,
        icon: icon,
      ).copyWith(counterText: ''),
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration:
          _buildInputDecoration(
            hintText: hintText,
            icon: Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
          ),
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: const Color(0xFF003DA5).withOpacity(0.15),
        width: 1.5,
      ),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFF003DA5), width: 2),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 10, right: 8),
        child: Center(
          widthFactor: 1,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF003DA5), size: 18),
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
    );
  }
}
