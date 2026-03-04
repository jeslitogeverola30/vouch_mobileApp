import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class EditReceiverDetailsScreen extends StatefulWidget {
  const EditReceiverDetailsScreen({super.key});

  @override
  State<EditReceiverDetailsScreen> createState() =>
      _EditReceiverDetailsScreenState();
}

class _EditReceiverDetailsScreenState extends State<EditReceiverDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _accountNameController;
  late final TextEditingController _positionController;
  late final TextEditingController _gcashNumberController;

  bool _isLoading = false;

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _fieldBorder = Color(0xFFDAE2EF);
  static const Color _fieldFill = Color(0xFFF8FAFD);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _titleText = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(text: 'Juan Dela Cruz');
    _positionController = TextEditingController(text: 'USC Treasurer');
    _gcashNumberController = TextEditingController(text: '09123456789');
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _positionController.dispose();
    _gcashNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receiver details updated successfully'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: 240,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _royalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                title: 'Receiver Setup',
                                subtitle:
                                    'Update payout details shown on payment screens',
                              ),
                              const SizedBox(height: 12),
                              _buildFormCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCardHeader(),
                                    const SizedBox(height: 20),
                                    _buildLabeledField(
                                      label: 'Account Name',
                                      child: TextFormField(
                                        controller: _accountNameController,
                                        textInputAction: TextInputAction.next,
                                        decoration: _buildInputDecoration(
                                          hintText: 'e.g., Juan Dela Cruz',
                                          icon: Ionicons.person_outline,
                                        ),
                                        validator: (value) {
                                          final text = value?.trim() ?? '';
                                          if (text.isEmpty) {
                                            return 'Please enter account name';
                                          }
                                          if (text.length < 3) {
                                            return 'Account name is too short';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Position',
                                      child: TextFormField(
                                        controller: _positionController,
                                        textInputAction: TextInputAction.next,
                                        decoration: _buildInputDecoration(
                                          hintText: 'e.g., USC Treasurer',
                                          icon: Ionicons.briefcase_outline,
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter position';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'GCash Number',
                                      child: TextFormField(
                                        controller: _gcashNumberController,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(11),
                                        ],
                                        decoration: _buildInputDecoration(
                                          hintText: '09XXXXXXXXX',
                                          icon: Ionicons.phone_portrait_outline,
                                        ).copyWith(counterText: ''),
                                        validator: (value) {
                                          final digits = value?.trim() ?? '';
                                          if (digits.isEmpty) {
                                            return 'Please enter GCash number';
                                          }
                                          final isValid = RegExp(
                                            r'^09\d{9}$',
                                          ).hasMatch(digits);
                                          if (!isValid) {
                                            return 'Use valid PH mobile format';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _fieldFill,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _fieldBorder),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 1,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: _royalBlue.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Ionicons
                                                  .information_circle_outline,
                                              color: _royalBlue,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'Ensure this number is active and verified before publishing updates.',
                                              style: TextStyle(
                                                color: _mutedText,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'These details are displayed to students when submitting payment proofs.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _mutedText.withOpacity(0.9),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomAction(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: _royalBlue),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Edit Receiver ',
                      style: TextStyle(color: _royalBlue),
                    ),
                    TextSpan(
                      text: 'Details',
                      style: TextStyle(color: _gold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _royalBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.black.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Ionicons.wallet_outline, color: _gold, size: 18),
        ),
        const SizedBox(width: 8),
        const Text(
          'RECIPIENT DETAILS',
          style: TextStyle(
            color: _mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _titleText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _mutedText, fontSize: 13),
      prefixIcon: Icon(icon, color: _royalBlue.withOpacity(0.6), size: 19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _royalBlue, width: 1.8),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFB3261E)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFB3261E), width: 1.5),
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _royalBlue.withOpacity(0.08))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: _royalBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: _royalBlue.withOpacity(0.55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
