import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EditReceiverDetailsScreen extends StatefulWidget {
  const EditReceiverDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EditReceiverDetailsScreen> createState() =>
      _EditReceiverDetailsScreenState();
}

class _EditReceiverDetailsScreenState extends State<EditReceiverDetailsScreen> {
  late TextEditingController _accountNameController;
  late TextEditingController _positionController;
  late TextEditingController _gcashNumberController;
  bool _isLoading = false;

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

  void _saveChanges() {
    if (_accountNameController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _gcashNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative background shapes
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF003DA5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Ionicons.chevron_back,
                          color: Color(0xFF003DA5),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Edit Receiver ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003DA5),
                              ),
                            ),
                            TextSpan(
                              text: 'Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFFFC107),
                          width: 4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Row(
                          children: [
                            Icon(
                              Ionicons.wallet,
                              color: const Color(0xFFFFC107),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'RECIPIENT DETAILS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFB0B0B0),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Account Name field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _accountNameController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                prefixIcon: Icon(
                                  Ionicons.person,
                                  color: const Color(0xFF003DA5).withOpacity(0.5),
                                  size: 20,
                                ),
                                hintText: 'e.g., Juan Dela Cruz',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF003DA5),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Position field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Position',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _positionController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                prefixIcon: Icon(
                                  Ionicons.briefcase,
                                  color: const Color(0xFF003DA5).withOpacity(0.5),
                                  size: 20,
                                ),
                                hintText: 'e.g., USC Treasurer',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF003DA5),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // GCash Number field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GCash Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _gcashNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                prefixIcon: Icon(
                                  Ionicons.phone_portrait,
                                  color: const Color(0xFF003DA5).withOpacity(0.5),
                                  size: 20,
                                ),
                                hintText: '09XX XXX XXXX',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF003DA5),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Info text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ensure that the GCash number is active and correct. This information will be displayed to students during payment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF003DA5).withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Save button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003DA5),
                        disabledBackgroundColor: const Color(0xFF003DA5)
                            .withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF003DA5),
        unselectedItemColor: const Color(0xFFB0B0B0),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.calendar),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.card),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
