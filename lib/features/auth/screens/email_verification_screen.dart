import 'package:flutter/material.dart';

import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  late final List<TextEditingController> _controllers;
  bool _isVerified = false;
  String _resendMessage = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.trim().isNotEmpty);

  void _verifyCode() {
    if (!_isCodeComplete) {
      return;
    }
    setState(() {
      _isVerified = true;
    });
  }

  void _resendCode() {
    setState(() {
      _resendMessage = 'Verification code sent! Please check your email.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerified) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -60,
              child: _BgCircle(size: 220, color: Color(0xFFFACC15)),
            ),
            const Positioned(
              bottom: -90,
              left: -80,
              child: _BgCircle(size: 240, color: Color(0xFF1D4ED8)),
            ),
            Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E),
                        ),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Code Verified! 🎉',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your account has been successfully verified. You can now sign in to your account.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        child: const Text('Sign In Now'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Email Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We\'ve sent a verification code to your email address. Please check your inbox and enter the code below.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 44,
                          child: TextField(
                            controller: _controllers[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(counterText: ''),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isCodeComplete ? _verifyCode : null,
                        child: const Text('Verify Code'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Didn\'t receive the code? '),
                        GestureDetector(
                          onTap: _resendCode,
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_resendMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _resendMessage,
                        style: const TextStyle(color: Color(0xFF10B981)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BgCircle extends StatelessWidget {
  const _BgCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
