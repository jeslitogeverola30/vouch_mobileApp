import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Pending';

  final List<PaymentSubmission> _submissions = [
    PaymentSubmission(
      id: '1',
      studentName: 'Maria Santos',
      studentProgram: 'BSCS - 3rd Year',
      courseName: 'Panaghigalaay 2025 T-Shirt',
      amount: '350.00',
      paymentMethod: 'GCash',
      timeAgo: '2m ago',
      avatarUrl: 'https://via.placeholder.com/50/6B5B95/FFFFFF?text=MS',
      proofFile: 'IMG_20250812_PROOF.jpg',
      status: 'Pending',
    ),
    PaymentSubmission(
      id: '2',
      studentName: 'Juan Dela Cruz',
      studentProgram: 'BSED - 2nd Year',
      courseName: 'General Assembly Fee',
      amount: '150.00',
      paymentMethod: 'Maya',
      timeAgo: '15m ago',
      avatarUrl: 'https://via.placeholder.com/50/6B5B95/FFFFFF?text=JDC',
      proofFile: 'PAYMENT_RECEIPT_001.pdf',
      status: 'Pending',
    ),
    PaymentSubmission(
      id: '3',
      studentName: 'Anna Reyes',
      studentProgram: 'BSIT - 1st Year',
      courseName: 'Membership Fee',
      amount: '200.00',
      paymentMethod: 'GCash',
      timeAgo: '1h ago',
      avatarUrl: 'https://via.placeholder.com/50/6B5B95/FFFFFF?text=AR',
      proofFile: 'PROOF_20250815.jpg',
      status: 'Pending',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showApprovalDialog(PaymentSubmission submission, bool isApprove) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          isApprove ? 'Approve Payment' : 'Reject Payment',
          style: const TextStyle(
            color: Color(0xFF003DA5),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          isApprove
              ? 'Approve ₱${submission.amount} payment from ${submission.studentName}?'
              : 'Reject ₱${submission.amount} payment from ${submission.studentName}?',
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF003DA5)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isApprove ? const Color(0xFF003DA5) : Colors.red,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isApprove
                        ? 'Payment approved successfully'
                        : 'Payment rejected',
                  ),
                  backgroundColor:
                      isApprove ? Colors.green : Colors.red.shade600,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Text(
                    'Manage Payments',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF003DA5),
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                  ),
                ),
                // Summary Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF003DA5),
                          Color(0xFF003DA5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Gold diagonal stripe
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC107),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'RECEIVER REFERENCE',
                                      style: TextStyle(
                                        color: Color(0xFFFFC107),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Juan Dela Cruz',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Treasurer - ACES',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'GCASH NUMBER',
                                      style: TextStyle(
                                        color: Color(0xFFFFC107),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'e912 345 6789',
                                      style: TextStyle(
                                        color: Color(0xFFFFC107),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFC107),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.circle,
                                      color: Color(0xFF003DA5),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Ionicons.pencil,
                                          color: Color(0xFF003DA5),
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Color(0xFF003DA5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
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
                const SizedBox(height: 24),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or student ID',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(
                        Ionicons.search,
                        color: Colors.grey,
                      ),
                      suffixIcon: const Icon(
                        Ionicons.settings_outline,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Pending', 'Approved', 'Rejected'].map((tab) {
                        final isActive = _selectedFilter == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedFilter = tab);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF003DA5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: !isActive
                                    ? Border.all(
                                        color: Colors.grey.shade300,
                                      )
                                    : null,
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Submissions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Submissions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF003DA5),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('View All tapped')),
                          );
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Submissions List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _submissions.map((submission) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        NetworkImage(submission.avatarUrl),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          submission.studentName,
                                          style: const TextStyle(
                                            color: Color(0xFF003DA5),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          submission.studentProgram,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          submission.courseName,
                                          style: const TextStyle(
                                            color: Color(0xFF2196F3),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₱${submission.amount}',
                                        style: const TextStyle(
                                          color: Color(0xFF003DA5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${submission.paymentMethod} • ${submission.timeAgo}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Ionicons.document,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      submission.proofFile,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Viewing proof: ${submission.proofFile}',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'View Proof',
                                      style: TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _showApprovalDialog(submission, false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Reject',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _showApprovalDialog(submission, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF003DA5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Ionicons.checkmark,
                                              color: Colors.white, size: 16),
                                          SizedBox(width: 4),
                                          Text(
                                            'Approve',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF003DA5),
        unselectedItemColor: Colors.grey,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new payment pressed')),
          );
        },
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(
          Ionicons.add,
          color: Color(0xFF003DA5),
          size: 28,
        ),
      ),
    );
  }
}

class PaymentSubmission {
  final String id;
  final String studentName;
  final String studentProgram;
  final String courseName;
  final String amount;
  final String paymentMethod;
  final String timeAgo;
  final String avatarUrl;
  final String proofFile;
  final String status;

  PaymentSubmission({
    required this.id,
    required this.studentName,
    required this.studentProgram,
    required this.courseName,
    required this.amount,
    required this.paymentMethod,
    required this.timeAgo,
    required this.avatarUrl,
    required this.proofFile,
    required this.status,
  });
}
