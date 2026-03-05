import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/auth_profile_sync_service.dart';
import '../data/supabase_auth_service.dart';
import '../domain/auth_validators.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;

  bool _isSending = false;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _hasRequestedCode = false;

  String _currentEmail = '';
  String _requestedEmail = '';

  @override
  void initState() {
    super.initState();
    _currentEmail = SupabaseAuthService.currentUser?.email ?? '';
    _emailController = TextEditingController(text: _currentEmail);
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final nextEmail = _emailController.text.trim().toLowerCase();

    if (!AuthValidators.isEmailAddress(nextEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address.')),
      );
      return;
    }

    if (_currentEmail.isNotEmpty && nextEmail == _currentEmail.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use a different email from your current one.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await SupabaseAuthService.requestEmailChange(newEmail: nextEmail);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
      _hasRequestedCode = true;
      _requestedEmail = nextEmail;
      _codeController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code sent.')));
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (!_hasRequestedCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Send a verification code first.')),
      );
      return;
    }

    if (!AuthValidators.isOtpCode(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 8-digit verification code.')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final previousEmail = _currentEmail;

    try {
      await SupabaseAuthService.verifyEmailChangeOtp(
        email: _requestedEmail,
        code: code,
      );
      await AuthProfileSyncService.syncCurrentUserEmail(
        previousEmail: previousEmail,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isVerifying = false;
      _currentEmail = SupabaseAuthService.currentUser?.email ?? _requestedEmail;
      _hasRequestedCode = false;
      _requestedEmail = '';
      _emailController.text = _currentEmail;
      _codeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email updated successfully.')),
    );

    Navigator.of(context).pop();
  }

  Future<void> _resendCode() async {
    if (!_hasRequestedCode || _requestedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Send a verification code first.')),
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      await SupabaseAuthService.resendEmailChangeOtp(email: _requestedEmail);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isResending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isResending = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code resent.')));
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
                                      'Change email',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF003DA5),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Enter your new email to receive an 8-digit code.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentEmail.isEmpty
                                          ? 'Current email unavailable'
                                          : 'Current: $_currentEmail',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: const Color(0xFF003DA5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        hintText: 'New email address',
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: _isSending
                                            ? null
                                            : _sendCode,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF003DA5,
                                          ),
                                          side: BorderSide(
                                            color: const Color(
                                              0xFF003DA5,
                                            ).withOpacity(0.25),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: _isSending
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'Send code',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _codeController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      textInputAction: TextInputAction.done,
                                      maxLength: 8,
                                      textAlign: TextAlign.center,
                                      onSubmitted: (_) {
                                        if (!_isVerifying) {
                                          _verifyCode();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: '8-digit code',
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
                                        onPressed: _isVerifying
                                            ? null
                                            : _verifyCode,
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _isVerifying
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
                                                'Verify and Update',
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
                                              child: CircularProgressIndicator(
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
    );
  }
}
