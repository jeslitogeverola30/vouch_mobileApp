import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../profile/services/supabase_profile_service.dart';
import '../../../routes/app_router.dart';
import '../services/supabase_auth_service.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFF003DA5).withOpacity(0.1),
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
                                28,
                                24,
                                24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/logos/vouch_logo.png',
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(width: 2),
                                      RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.poppins(
                                            fontSize: 34,
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
                                  const SizedBox(height: 8),
                                  Text(
                                    'Welcome back',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 26),
                                  _buildEmailField(),
                                  const SizedBox(height: 14),
                                  _buildPasswordField(),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _handleLogin,
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
                                              'Login',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF003DA5),
                                    ),
                                    child: Text(
                                      'Forgot your password?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Sign Up',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF003DA5),
                                          ),
                                        ),
                                      ),
                                    ],
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
    );
  }

  Future<void> _handleLogin() async {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await SupabaseAuthService.signInWithPassword(
        email: identifier,
        password: password,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().toLowerCase();
      final requiresVerification =
          message.contains('email not confirmed') ||
          message.contains('email_not_confirmed');

      if (requiresVerification) {
        await SupabaseAuthService.sendSignInOtp(email: identifier);

        if (!mounted) {
          return;
        }

        setState(() => _isSubmitting = false);

        Navigator.of(
          context,
        ).pushNamed(AppRouter.signInVerification, arguments: identifier);
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

    setState(() => _isSubmitting = false);

    if (SupabaseAuthService.currentUser != null) {
      try {
        await SupabaseProfileService.ensureCurrentUserProfile();
      } catch (_) {}

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.studentHome, (route) => false);
      return;
    }

    const fallbackMessage = 'Invalid email or password.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(fallbackMessage)));
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: _buildInputDecoration(
        hintText: 'Enter your email',
        icon: Icons.mail_outline,
      ),
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      autocorrect: false,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration:
          _buildInputDecoration(
            hintText: 'Enter your password',
            icon: Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility,
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
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        if (!_isSubmitting) {
          _handleLogin();
        }
      },
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
      filled: true,
      fillColor: Colors.white,
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
