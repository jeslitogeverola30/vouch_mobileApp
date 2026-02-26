import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_router.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late final TextEditingController _codeController;
  bool _isSubmitting = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final authState = ClerkAuth.of(context, listen: false);
      if (authState.user != null) {
        _goToHome();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the verification code.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final authState = ClerkAuth.of(context, listen: false);

    await authState.safelyCall(
      context,
      () => authState.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        code: code,
      ),
    );

    await authState.safelyCall(context, () => authState.refreshClient());

    if (!mounted) {
      return;
    }

    if (authState.user != null ||
        authState.signUp?.status == clerk.Status.complete) {
      _goToHome();
      return;
    }

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification not complete yet.')),
    );
  }

  void _goToHome() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.studentHome, (route) => false);
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    final authState = ClerkAuth.of(context, listen: false);

    await authState.safelyCall(
      context,
      () => authState.attemptSignUp(strategy: clerk.Strategy.emailCode),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isResending = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code sent.')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: ClerkErrorListener(
          child: SafeArea(
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
                                        'Verify your email',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF003DA5),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Enter the 6-digit code sent to',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.email,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: const Color(0xFF003DA5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        controller: _codeController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        maxLength: 6,
                                        textAlign: TextAlign.center,
                                        onSubmitted: (_) {
                                          if (!_isSubmitting) {
                                            _verifyCode();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          hintText: '6-digit code',
                                          counterText: '',
                                          hintStyle: GoogleFonts.poppins(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: const Color(
                                                0xFF003DA5,
                                              ).withOpacity(0.15),
                                              width: 1.5,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: BorderSide(
                                              color: const Color(
                                                0xFF003DA5,
                                              ).withOpacity(0.15),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF003DA5),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          letterSpacing: 6,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 52,
                                        child: ElevatedButton(
                                          onPressed: _isSubmitting
                                              ? null
                                              : _verifyCode,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFFFC107,
                                            ),
                                            foregroundColor: const Color(
                                              0xFF003DA5,
                                            ),
                                            disabledBackgroundColor:
                                                const Color(
                                                  0xFFFFC107,
                                                ).withOpacity(0.6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            elevation: 0,
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
                                                  'Verify Email',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _isResending
                                            ? null
                                            : _resendCode,
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF003DA5,
                                          ),
                                        ),
                                        child: _isResending
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'Resend code',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
