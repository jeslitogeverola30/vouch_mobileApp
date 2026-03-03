import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CreateFeeScreen extends StatefulWidget {
  const CreateFeeScreen({Key? key}) : super(key: key);

  @override
  State<CreateFeeScreen> createState() => _CreateFeeScreenState();
}

class _CreateFeeScreenState extends State<CreateFeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _feeTitle;
  late TextEditingController _amount;
  late TextEditingController _dueDate;
  late TextEditingController _instructions;
  bool _isObligatory = false;

  @override
  void initState() {
    super.initState();
    _feeTitle = TextEditingController();
    _amount = TextEditingController(text: '0.00');
    _dueDate = TextEditingController();
    _instructions = TextEditingController();
  }

  @override
  void dispose() {
    _feeTitle.dispose();
    _amount.dispose();
    _dueDate.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003DA5),
              onPrimary: Colors.white,
              onSurface: Color(0xFF003DA5),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dueDate.text = '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleCreateFee() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fee created successfully!'),
          backgroundColor: Color(0xFF003DA5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Decorative background shapes
          Positioned(
            top: 0,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF003DA5).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC107).withOpacity(0.08),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Create New ',
                                  style: TextStyle(
                                    color: Color(0xFF003DA5),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Fee',
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Main form card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFFFFC107),
                          width: 6,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // FEE DETAILS header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC107).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Ionicons.wallet,
                                    color: Color(0xFFFFC107),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'FEE DETAILS',
                                  style: TextStyle(
                                    color: Color(0xFFA0AEC0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Fee Title
                            const Text(
                              'Fee Title',
                              style: TextStyle(
                                color: Color(0xFF1A202C),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _feeTitle,
                              decoration: InputDecoration(
                                hintText: 'e.g., Annual Membership Fee',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA0AEC0),
                                  fontSize: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF003DA5),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a fee title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Amount and Due Date Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Amount',
                                        style: TextStyle(
                                          color: Color(0xFF1A202C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _amount,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          prefixText: '₱ ',
                                          prefixStyle: const TextStyle(
                                            color: Color(0xFF1A202C),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          hintText: '0.00',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFFA0AEC0),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF003DA5),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7FAFC),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter an amount';
                                          }
                                          if (double.tryParse(value.replaceFirst('₱ ', '')) == null) {
                                            return 'Invalid amount';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Due Date',
                                        style: TextStyle(
                                          color: Color(0xFF1A202C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _dueDate,
                                        readOnly: true,
                                        onTap: () => _selectDueDate(context),
                                        decoration: InputDecoration(
                                          hintText: 'mm/dd/yyyy',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFFA0AEC0),
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 12),
                                            child: Icon(
                                              Ionicons.calendar,
                                              color: const Color(0xFF003DA5).withOpacity(0.5),
                                              size: 20,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF003DA5),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7FAFC),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a date';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Obligatory Fee Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Obligatory Fee?',
                                      style: TextStyle(
                                        color: Color(0xFF1A202C),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Is this payment mandatory for all?',
                                      style: TextStyle(
                                        color: Color(0xFFA0AEC0),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _isObligatory,
                                  onChanged: (value) {
                                    setState(() {
                                      _isObligatory = value;
                                    });
                                  },
                                  activeColor: const Color(0xFFFFC107),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.grey[300],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Instructions/Note
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Instructions / Note',
                                  style: TextStyle(
                                    color: Color(0xFF1A202C),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Optional',
                                  style: TextStyle(
                                    color: const Color(0xFFA0AEC0),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _instructions,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Add payment instructions or special notes for students here...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFA0AEC0),
                                  fontSize: 13,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF003DA5),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF7FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Info text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'By creating this fee, it will become immediately visible to all eligible students in the DOrSU system.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFA0AEC0),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Create Fee Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleCreateFee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003DA5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Create Fee',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF003DA5),
          unselectedItemColor: Color(0xFFA0AEC0),
          onTap: (index) {
            // Handle navigation
          },
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
              icon: Icon(Ionicons.wallet),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Ionicons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
