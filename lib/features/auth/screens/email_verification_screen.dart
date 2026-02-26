import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

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

    if (!mounted) {
      return;
    }

    if (authState.signUp?.status == clerk.Status.complete) {
      await authState.refreshClient();
      if (authState.user != null) {
        await authState.signOut();
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified. Please log in.')),
      );

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
      return;
    }

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification not complete yet.')),
    );
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF003DA5),
        elevation: 0,
      ),
      body: ClerkErrorListener(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter the code sent to ${widget.email}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF003DA5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '6-digit code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF003DA5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Verify Email',
                            style: TextStyle(
                              color: Color(0xFF003DA5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: _isResending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Resend code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
