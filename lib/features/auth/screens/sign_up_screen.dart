import 'package:flutter/material.dart';

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
  static const Color borderGray = Color(0xFFE0E0E0);
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          // Background decorative shapes
          _buildBackgroundShapes(context),

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24.0 : 48.0,
                vertical: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 20),

                  // Header
                  Center(
                    child: Text(
                      'Sign Up',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            fontSize: isMobile ? 28 : 32,
                          ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 32 : 48),

                  // Faculty Dropdown
                  _buildLabel('Faculty'),
                  _buildDropdown(
                    hint: 'Select Faculty',
                    value: selectedFaculty,
                    items: faculties,
                    onChanged: (value) {
                      setState(() => selectedFaculty = value);
                    },
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  // Degree Dropdown
                  _buildLabel("Bachelor's Degree"),
                  _buildDropdown(
                    hint: 'Select Degree',
                    value: selectedDegree,
                    items: degrees,
                    onChanged: (value) {
                      setState(() => selectedDegree = value);
                    },
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  // Full Name
                  _buildLabel('Full Name'),
                  _buildTextField(
                    controller: fullNameController,
                    hint: 'Enter Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  // School ID fields
                  _buildLabel('School ID No.'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: schoolIDFirstController,
                          hint: 'XXXX',
                          maxLength: 4,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: schoolIDSecondController,
                          hint: 'XXXX',
                          maxLength: 4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  // Email
                  _buildLabel('Email'),
                  _buildTextField(
                    controller: emailController,
                    hint: 'Enter Email',
                    prefixIcon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  // Password
                  _buildLabel('Password'),
                  _buildPasswordField(
                    controller: passwordController,
                    hint: 'Enter Password',
                    isVisible: showPassword,
                    onToggle: () {
                      setState(() => showPassword = !showPassword);
                    },
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  // Confirm Password
                  _buildLabel('Confirm Password'),
                  _buildPasswordField(
                    controller: confirmPasswordController,
                    hint: 'Re-enter Password',
                    isVisible: showConfirmPassword,
                    onToggle: () {
                      setState(
                        () => showConfirmPassword = !showConfirmPassword,
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 28 : 40),

                  // Sign Up Button
                  _buildSignUpButton(context),
                  SizedBox(height: isMobile ? 20 : 24),

                  // Sign In Link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: darkText),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Sign In',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: royalBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundShapes(BuildContext context) {
    return Stack(
      children: [
        // Top blue shape
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
        // Bottom gold shape
        Positioned(
          bottom: -80,
          left: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              color: gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(175),
            ),
          ),
        ),
        // Right side decorative shape
        Positioned(
          top: 200,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: royalBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(150),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: darkText,
          fontWeight: FontWeight.w600,
          fontSize: 14,
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
        border: Border.all(color: borderGray, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              hint,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          value: value,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(item),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Icon(Icons.expand_more, color: royalBlue),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderGray, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: white,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(prefixIcon, color: gold, size: 20),
                )
              : null,
          prefixIconConstraints: prefixIcon != null
              ? const BoxConstraints(minWidth: 0, minHeight: 0)
              : null,
          counterText: '',
        ),
        style: const TextStyle(color: darkText, fontSize: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderGray, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: white,
      ),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.lock_outline, color: gold, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: royalBlue,
                size: 20,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
        style: const TextStyle(color: darkText, fontSize: 14),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Handle sign up
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign Up button pressed')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Sign Up',
          style: TextStyle(
            color: royalBlue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
