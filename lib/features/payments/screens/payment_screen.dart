import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import '../../../core/widgets/app_bottom_navigation_bar.dart';
import 'proof_of_payment_screen.dart';
import '../../../routes/app_router.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedTab = 'All';
  int _selectedNavIndex = 3;

  final String studentId = '2023-0222';
  final String academicYear = 'A.Y. 2025-2026';
  final double totalPayable = 200.00;

  final List<Map<String, dynamic>> paymentItems = [
    {
      'name': 'Donation',
      'amount': 'Any Amount',
      'dueDate': 'February 28, 2026',
      'proof': 'Screenshot_20260228.jpg',
      'status': 'Pending',
      'obligation': 'NON-OBLIGATORY',
      'actionText': 'Awaiting Admin Verification...',
    },
    {
      'name': 'Membership Fee',
      'amount': '₱200.00',
      'dueDate': 'February 28, 2026',
      'proof': 'N/A',
      'status': 'To Pay',
      'obligation': 'OBLIGATORY',
      'actionText': 'Submit Proof of Payment',
    },
    {
      'name': 'CB Polo Shirt Batch 1',
      'amount': '₱500.00',
      'dueDate': 'March 15, 2026',
      'proof': 'N/A',
      'status': 'To Pay',
      'obligation': 'OBLIGATORY',
      'actionText': 'Submit Proof of Payment',
    },
  ];

  List<Map<String, dynamic>> get _filteredPayments {
    if (selectedTab == 'Pending') {
      return paymentItems.where((item) => item['status'] == 'Pending').toList();
    }
    if (selectedTab == 'To Pay') {
      return paymentItems.where((item) => item['status'] == 'To Pay').toList();
    }
    return paymentItems;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 260,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF003DA5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 18),
                          _buildTabs(),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: _filteredPayments
                                  .map(
                                    (payment) => _PaymentCard(
                                      payment: payment,
                                      onActionTap: () =>
                                          _handlePaymentAction(payment),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: _onNavTapped,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/logos/vouch_logo.png',
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 2),
              Transform.translate(
                offset: const Offset(-2, 0),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: 'ou',
                        style: TextStyle(color: Color(0xFF003DA5)),
                      ),
                      TextSpan(
                        text: 'ch',
                        style: TextStyle(color: Color(0xFFFFC107)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Ionicons.search, color: Color(0xFF003DA5)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Ionicons.notifications,
                  color: Color(0xFF003DA5),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/my_profile.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF1F37A6),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _SummaryYellowPanelClipper(),
                  child: Container(color: const Color(0xFFECCB2B)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL PAYABLE',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFAFC0F1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '₱ ${totalPayable.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 56,
                                  height: 0.95,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/logos/vouch_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          academicYear,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFAFC0F1),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          studentId,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1F37A6),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const tabs = ['All', 'Pending', 'To Pay'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = selectedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => selectedTab = tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF003DA5) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF003DA5)
                          : const Color(0xFF003DA5).withOpacity(0.18),
                    ),
                  ),
                  child: Text(
                    tab,
                    style: GoogleFonts.poppins(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF003DA5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onNavTapped(int index) {
    if (index == _selectedNavIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRouter.studentHome);
      return;
    }

    if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRouter.events);
      return;
    }

    if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRouter.myQrCode);
      return;
    }

    if (index == 4) {
      Navigator.pushReplacementNamed(context, AppRouter.profile);
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _handlePaymentAction(Map<String, dynamic> payment) {
    final status = (payment['status'] as String? ?? '').trim();
    if (status != 'To Pay') {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProofOfPaymentScreen(
          paymentItem: payment['name'] as String? ?? 'Payment Item',
          amountToPay: payment['amount'] as String? ?? 'N/A',
        ),
      ),
    );
  }
}

class _SummaryYellowPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.79, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.63, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onActionTap;

  const _PaymentCard({required this.payment, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final isPending = payment['status'] == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment['name'],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF003DA5),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                payment['amount'],
                style: GoogleFonts.poppins(
                  color: const Color(0xFF003DA5),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: ${payment['dueDate']}',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFFC107).withOpacity(0.2)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment['status'],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF003DA5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Proof: ${payment['proof']}',
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            payment['obligation'],
            style: GoogleFonts.poppins(
              color: Colors.black45,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: const Color(0xFF003DA5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (isPending) {
                  return;
                }
                onActionTap();
              },
              child: Text(
                payment['actionText'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
