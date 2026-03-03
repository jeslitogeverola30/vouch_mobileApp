import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
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
      avatarText: 'MS',
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
      avatarText: 'JD',
      proofFile: 'PAYMENT_RECEIPT_001.pdf',
      status: 'Approved',
    ),
    PaymentSubmission(
      id: '3',
      studentName: 'Anna Reyes',
      studentProgram: 'BSIT - 1st Year',
      courseName: 'Membership Fee',
      amount: '200.00',
      paymentMethod: 'GCash',
      timeAgo: '1h ago',
      avatarText: 'AR',
      proofFile: 'PROOF_20250815.jpg',
      status: 'Rejected',
    ),
    PaymentSubmission(
      id: '4',
      studentName: 'Paolo Ramirez',
      studentProgram: 'BSIT - 4th Year',
      courseName: 'Foundation Week Donation',
      amount: '500.00',
      paymentMethod: 'Bank Transfer',
      timeAgo: '3h ago',
      avatarText: 'PR',
      proofFile: 'TRANSFER_PROOF_141.jpg',
      status: 'Pending',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PaymentSubmission> get _filteredSubmissions {
    final query = _searchController.text.trim().toLowerCase();

    return _submissions.where((submission) {
      final matchesStatus = submission.status == _selectedFilter;
      final matchesQuery =
          query.isEmpty ||
          submission.studentName.toLowerCase().contains(query) ||
          submission.studentProgram.toLowerCase().contains(query) ||
          submission.courseName.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  int _countByStatus(String status) {
    return _submissions
        .where((submission) => submission.status == status)
        .length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF2E7D32);
      case 'Rejected':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF003DA5);
    }
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
              backgroundColor: isApprove ? const Color(0xFF003DA5) : Colors.red,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isApprove
                        ? 'Payment approved successfully'
                        : 'Payment rejected',
                  ),
                  backgroundColor: isApprove
                      ? Colors.green
                      : Colors.red.shade600,
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
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    final filteredSubmissions = _filteredSubmissions;

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 70,
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
              bottom: 180,
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
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF003DA5).withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Payment ',
                                  style: TextStyle(
                                    color: Color(0xFF003DA5),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Review',
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Verify proof submissions and keep collection status up to date',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildCountChip(
                                'Pending',
                                _countByStatus('Pending'),
                              ),
                              _buildCountChip(
                                'Approved',
                                _countByStatus('Approved'),
                              ),
                              _buildCountChip(
                                'Rejected',
                                _countByStatus('Rejected'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    title: 'Search & Filter',
                    subtitle: 'Narrow down payment submissions quickly',
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by student name, program, or fee',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Ionicons.search,
                          color: Color(0xFF003DA5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF003DA5).withOpacity(0.12),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: const Color(0xFF003DA5).withOpacity(0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF003DA5),
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Pending', 'Approved', 'Rejected'].map((
                          tab,
                        ) {
                          final isActive = _selectedFilter == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () =>
                                    setState(() => _selectedFilter = tab),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  curve: Curves.easeOut,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF003DA5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive
                                          ? const Color(0xFF003DA5)
                                          : const Color(
                                              0xFF003DA5,
                                            ).withOpacity(0.18),
                                    ),
                                  ),
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF003DA5),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
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
                  _buildSectionHeader(
                    title: 'Submissions',
                    subtitle:
                        '${filteredSubmissions.length} result(s) in $_selectedFilter',
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: filteredSubmissions.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: filteredSubmissions
                                .map(
                                  (submission) =>
                                      _buildSubmissionCard(submission),
                                )
                                .toList(),
                          ),
                  ),
                ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF003DA5),
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildCountChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(
          color: Color(0xFF003DA5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Ionicons.search,
            color: const Color(0xFF003DA5).withOpacity(0.5),
            size: 24,
          ),
          const SizedBox(height: 8),
          const Text(
            'No submissions found',
            style: TextStyle(
              color: Color(0xFF003DA5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different search term or filter',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(PaymentSubmission submission) {
    final statusColor = _statusColor(submission.status);
    final isPending = submission.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF003DA5).withOpacity(0.12),
                child: Text(
                  submission.avatarText,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      submission.courseName,
                      style: const TextStyle(
                        color: Color(0xFF003DA5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      submission.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Ionicons.wallet_outline,
                color: Colors.black45,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${submission.paymentMethod} • ${submission.timeAgo}',
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Ionicons.document_text_outline,
                  color: Colors.black54,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    submission.proofFile,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing proof: ${submission.proofFile}'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF003DA5),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showApprovalDialog(submission, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC62828),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApprovalDialog(submission, true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF003DA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                submission.status == 'Approved'
                    ? 'Already approved'
                    : 'Already rejected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
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
  final String avatarText;
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
    required this.avatarText,
    required this.proofFile,
    required this.status,
  });
}
