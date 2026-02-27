import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_router.dart';
import '../services/supabase_auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Color constants
  static const Color royalBlue = Color(0xFF003DA5);
  static const Color gold = Color(0xFFFFC107);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1A1A1A);

  // Form controllers
  late TextEditingController fullNameController;
  late TextEditingController schoolIDFirstController;
  late TextEditingController schoolIDSecondController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // Form state
  String? selectedFaculty;
  String? selectedDegree;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isSubmitting = false;

  // Sample data
  final List<String> faculties = [
    'Faculty 1',
    'Faculty 2',
    'Faculty 3',
    'Faculty 4',
  ];
  final List<String> degrees = [
    'Bachelor 1',
    'Bachelor 2',
    'Bachelor 3',
    'Bachelor 4',
  ];

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    schoolIDFirstController = TextEditingController();
    schoolIDSecondController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    schoolIDFirstController.dispose();
    schoolIDSecondController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: white,
        body: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundShapes(context),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: royalBlue.withOpacity(0.1),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                            style: TextStyle(color: royalBlue),
                                          ),
                                          TextSpan(
                                            text: 'ch',
                                            style: TextStyle(color: gold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Create your account',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildLabel('Faculty'),
                              _buildDropdown(
                                hint: 'Select Faculty',
                                value: selectedFaculty,
                                items: faculties,
                                onChanged: (value) {
                                  setState(() => selectedFaculty = value);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildLabel("Bachelor's Degree"),
                              _buildDropdown(
                                hint: 'Select Degree',
                                value: selectedDegree,
                                items: degrees,
                                onChanged: (value) {
                                  setState(() => selectedDegree = value);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Full Name'),
                              _buildTextField(
                                controller: fullNameController,
                                hint: 'Enter Full Name',
                                prefixIcon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('School ID No.'),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: schoolIDFirstController,
                                      hint: 'XXXX',
                                      maxLength: 4,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: schoolIDSecondController,
                                      hint: 'XXXX',
                                      maxLength: 4,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Email'),
                              _buildTextField(
                                controller: emailController,
                                hint: 'Enter Email',
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Password'),
                              _buildPasswordField(
                                controller: passwordController,
                                hint: 'Enter Password',
                                isVisible: showPassword,
                                onToggle: () {
                                  setState(() => showPassword = !showPassword);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildLabel('Confirm Password'),
                              _buildPasswordField(
                                controller: confirmPasswordController,
                                hint: 'Re-enter Password',
                                isVisible: showConfirmPassword,
                                onToggle: () {
                                  setState(() {
                                    showConfirmPassword = !showConfirmPassword;
                                  });
                                },
                              ),
                              const SizedBox(height: 22),
                              _buildSignUpButton(context),
                              const SizedBox(height: 10),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: darkText,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: royalBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Future<void> _handleSignUp() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    final names = fullName.split(' ').where((part) => part.isNotEmpty).toList();
    final firstName = names.isNotEmpty ? names.first : null;
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : null;

    setState(() => isSubmitting = true);

    try {
      await SupabaseAuthService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => isSubmitting = false);

    Navigator.of(
      context,
    ).pushNamed(AppRouter.emailVerification, arguments: email);
  }

  Widget _buildBackgroundShapes(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 70,
          right: -50,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.16),
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
              color: royalBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: darkText,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: royalBlue.withOpacity(0.15), width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              hint,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          value: value,
          style: GoogleFonts.poppins(
            color: darkText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(item),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.expand_more_rounded, color: royalBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: _buildInputDecoration(
        hintText: hint,
        icon: prefixIcon,
      ).copyWith(counterText: ''),
      style: GoogleFonts.poppins(
        color: darkText,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration:
          _buildInputDecoration(
            hintText: hint,
            icon: Icons.lock_outline,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: royalBlue,
                size: 20,
              ),
            ),
          ),
      style: GoogleFonts.poppins(
        color: darkText,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    IconData? icon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: royalBlue.withOpacity(0.15), width: 1.5),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey.shade500,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: royalBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: icon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Center(
                widthFactor: 1,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: royalBlue, size: 18),
                ),
              ),
            ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: royalBlue,
          disabledBackgroundColor: gold.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003DA5)),
                ),
              )
            : Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  color: royalBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
