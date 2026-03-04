import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import 'admin_create_fee_screen.dart';
import 'admin_edit_receiver_details_screen.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const String _allFeeTypesLabel = 'All Fee Types';
  String _selectedFilter = 'Pending';
  String _selectedFeeType = _allFeeTypesLabel;
  final String _receiverName = 'Juan Dela Cruz';
  final String _receiverRole = 'Treasurer - ACES';
  final String _receiverNumber = '0912 345 6789';

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
      proofFile: 'receipt-sample1.jpg',
      receiptAssetPath: 'assets/images/receipt-sample1.jpg',
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
      proofFile: 'receipt-sample2.jpg',
      receiptAssetPath: 'assets/images/receipt-sample2.jpg',
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
      proofFile: 'receipt-sample1.jpg',
      receiptAssetPath: 'assets/images/receipt-sample1.jpg',
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
      proofFile: 'receipt-sample2.jpg',
      receiptAssetPath: 'assets/images/receipt-sample2.jpg',
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

  List<String> get _feeTypeOptions {
    final feeTypes =
        _submissions.map((submission) => submission.courseName).toSet().toList()
          ..sort();

    return [_allFeeTypesLabel, ...feeTypes];
  }

  List<PaymentSubmission> get _filteredSubmissions {
    final query = _searchController.text.trim().toLowerCase();

    return _submissions.where((submission) {
      final matchesStatus = submission.status == _selectedFilter;
      final matchesFeeType =
          _selectedFeeType == _allFeeTypesLabel ||
          submission.courseName == _selectedFeeType;
      final matchesQuery =
          query.isEmpty ||
          submission.studentName.toLowerCase().contains(query) ||
          submission.studentProgram.toLowerCase().contains(query) ||
          submission.courseName.toLowerCase().contains(query);

      return matchesStatus && matchesFeeType && matchesQuery;
    }).toList();
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

  void _showReceiptPreview(PaymentSubmission submission) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Receipt Preview',
                        style: TextStyle(
                          color: Color(0xFF003DA5),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Ionicons.close,
                        color: Color(0xFF003DA5),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                Text(
                  submission.proofFile,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.72,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFEEF2FA),
                      child: Image.asset(
                        submission.receiptAssetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            height: 280,
                            child: Center(
                              child: Text(
                                'Receipt sample not found',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFeeTypePicker() async {
    final selectedFeeType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = _feeTypeOptions;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Filter by Fee Type',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a fee to narrow down submissions',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final feeType = options[index];
                      final isSelected = _selectedFeeType == feeType;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(feeType),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF003DA5).withOpacity(0.08)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF003DA5)
                                    : const Color(0xFF003DA5).withOpacity(0.14),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    feeType,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF003DA5)
                                          : Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Ionicons.checkmark_circle,
                                    color: Color(0xFF003DA5),
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedFeeType == null || selectedFeeType == _selectedFeeType) {
      return;
    }

    setState(() => _selectedFeeType = selectedFeeType);
  }

  String get _feeTypeFilterLabel {
    if (_selectedFeeType == _allFeeTypesLabel) {
      return 'All Fees';
    }

    return _selectedFeeType;
  }

  Widget _buildInlineFeeTypeFilter() {
    return Material(
      color: const Color(0xFF003DA5).withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _showFeeTypePicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Ionicons.funnel_outline,
                color: Color(0xFF003DA5),
                size: 14,
              ),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 145),
                child: Text(
                  _feeTypeFilterLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Ionicons.chevron_down,
                color: Color(0xFF003DA5),
                size: 14,
              ),
            ],
          ),
        ),
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
                  const SizedBox(height: 16),
                  _buildReceiverReferenceCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    title: 'Search & Filter',
                    subtitle: 'Narrow down payment submissions quickly',
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 58),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF003DA5).withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Ionicons.search,
                            color: Color(0xFF003DA5),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Search by student name, program, or fee',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildInlineFeeTypeFilter(),
                          ),
                        ],
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
                        '${filteredSubmissions.length} result(s) in $_selectedFilter • ${_selectedFeeType == _allFeeTypesLabel ? 'all fees' : _selectedFeeType}',
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
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                heroTag: 'admin_payments_add_fab',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateFeeScreen()),
                  );
                },
                backgroundColor: const Color(0xFF003DA5),
                foregroundColor: Colors.white,
                elevation: 8,
                highlightElevation: 10,
                shape: const CircleBorder(),
                child: const Icon(Ionicons.add, size: 28),
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

  Widget _buildReceiverReferenceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 208,
        decoration: BoxDecoration(
          color: const Color(0xFF1F37A6),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _ReceiverYellowPanelClipper(),
                  child: Container(color: const Color(0xFFECCB2B)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 20, 16),
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
                                'RECEIVER REFERENCE',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _receiverName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 0.95,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _receiverRole,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 54,
                          height: 54,
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
                    Text(
                      'GCASH NUMBER',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFAFC0F1),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _receiverNumber,
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 0.95,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EditReceiverDetailsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Ionicons.create_outline, size: 18),
                            label: Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F37A6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                            ),
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
                  onPressed: () => _showReceiptPreview(submission),
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

class _ReceiverYellowPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.79, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.62, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
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
  final String receiptAssetPath;
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
    required this.receiptAssetPath,
    required this.status,
  });
}
