import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/global_header_search.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_main_header.dart';
import '../../data/payment_requirement_service.dart';
import '../../data/student_transaction_service.dart';
import '../../data/student_payment_seed_data.dart';
import '../../domain/student_payment_filters.dart';
import '../../domain/student_payment_item.dart';
import 'proof_of_payment_screen.dart';
import '../../../../core/config/app_router.dart';

class PaymentsScreen extends StatefulWidget {
  final bool showChrome;

  const PaymentsScreen({super.key, this.showChrome = true});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String selectedTab = StudentPaymentTab.all;
  int _selectedNavIndex = 3;

  final StudentPaymentSummary _summary = StudentPaymentSeedData.summary;
  final List<StudentPaymentItem> _paymentItems = [];
  bool _isLoadingFees = false;
  String? _feesErrorMessage;
  double _totalPayable = 0;

  @override
  void initState() {
    super.initState();
    _loadCreatedFees();
  }

  List<StudentPaymentItem> get _filteredPayments {
    return StudentPaymentFilters.filterByTab(
      items: _paymentItems,
      tab: selectedTab,
    );
  }

  Future<void> _loadCreatedFees() async {
    setState(() {
      _isLoadingFees = true;
      _feesErrorMessage = null;
    });

    try {
      final createdFees = await PaymentRequirementService.instance
          .fetchRequirementsForStudents();

      final currentStudentId = await StudentTransactionService.instance
          .resolveCurrentStudentId();

      final transactions = await StudentTransactionService.instance
          .fetchTransactionsForCurrentStudent();
      final transactionsByRequirement = <int, StudentTransactionRecord>{
        for (final transaction in transactions)
          if (transaction.requirementId > 0 &&
              transaction.studentId.trim() == currentStudentId)
            transaction.requirementId: transaction,
      };

      final mappedFees = createdFees
          .map(
            (fee) =>
                _mapRequirementToItem(fee, transactionsByRequirement[fee.id]),
          )
          .toList();
      final nextTotal = createdFees.fold<double>(0, (total, fee) {
        final status = _resolveCardStatus(
          transactionsByRequirement[fee.id]?.status,
        );
        final isPayable = status != StudentPaymentStatus.paid;

        return isPayable ? total + fee.amount : total;
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _paymentItems
          ..clear()
          ..addAll(mappedFees);
        _totalPayable = nextTotal;
      });
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _paymentItems.clear();
        _totalPayable = 0;
        _feesErrorMessage = _supabaseErrorMessage(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _paymentItems.clear();
        _totalPayable = 0;
        _feesErrorMessage = 'Unable to load created fees. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingFees = false);
      }
    }
  }

  StudentPaymentItem _mapRequirementToItem(
    PaymentRequirementDetails fee,
    StudentTransactionRecord? transaction,
  ) {
    final status = _resolveCardStatus(transaction?.status);

    return StudentPaymentItem(
      requirementId: fee.id,
      name: fee.title.isNotEmpty ? fee.title : 'Untitled Fee',
      amount: '₱${fee.amount.toStringAsFixed(2)}',
      dueDate: _extractDueDate(fee.description),
      proof: _resolveProofLabel(transaction),
      status: status,
      obligation: fee.isMandatory ? 'OBLIGATORY' : 'NON-OBLIGATORY',
      actionText: _resolveActionText(status),
      rejectionNote: transaction?.reviewNote ?? '',
    );
  }

  String _resolveCardStatus(String? rawStatus) {
    final normalized = (rawStatus ?? '').trim().toLowerCase();

    if (normalized.isEmpty || normalized == 'to_pay') {
      return StudentPaymentStatus.toPay;
    }

    if (normalized == 'pending' || normalized == 'for_review') {
      return StudentPaymentStatus.pending;
    }

    if (normalized == 'paid' ||
        normalized == 'approved' ||
        normalized == 'verified') {
      return StudentPaymentStatus.paid;
    }

    if (normalized == 'rejected' || normalized == 'declined') {
      return StudentPaymentStatus.rejected;
    }

    return StudentPaymentStatus.pending;
  }

  String _resolveProofLabel(StudentTransactionRecord? transaction) {
    if (transaction == null) {
      return 'N/A';
    }

    final reference = transaction.referenceNumber.trim();
    if (reference.isNotEmpty) {
      return reference;
    }

    final proofUrl = transaction.proofPhotoUrl.trim();
    if (proofUrl.isNotEmpty) {
      return 'Uploaded';
    }

    return 'Submitted';
  }

  String _resolveActionText(String status) {
    if (status == StudentPaymentStatus.pending) {
      return 'Awaiting Admin Verification...';
    }

    if (status == StudentPaymentStatus.paid) {
      return 'Payment Verified';
    }

    if (status == StudentPaymentStatus.rejected) {
      return 'Submit Proof Again';
    }

    return 'Submit Proof of Payment';
  }

  String _extractDueDate(String description) {
    final match = RegExp(
      r'Due Date:\s*([^\n\r]+)',
      caseSensitive: false,
    ).firstMatch(description);

    final dueDate = match?.group(1)?.trim() ?? '';
    if (dueDate.isNotEmpty) {
      return dueDate;
    }

    return 'No due date';
  }

  String _supabaseErrorMessage(PostgrestException error) {
    final message = error.message.trim();
    if (message.isNotEmpty) {
      return message;
    }

    final errorCode = error.code?.trim() ?? '';
    if (errorCode.isNotEmpty) {
      return 'Supabase request failed ($errorCode).';
    }

    return 'Unexpected database error. Please try again.';
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
            widget.showChrome
                ? SafeArea(child: _buildMainContent())
                : _buildMainContent(),
          ],
        ),
        bottomNavigationBar: widget.showChrome
            ? AppBottomNavigationBar(
                currentIndex: _selectedNavIndex,
                onTap: _onNavTapped,
              )
            : null,
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChrome)
          AppMainHeader(onSearchTap: () => openGlobalHeaderSearch(context)),
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
                  child: _buildPaymentsContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsContent() {
    if (_isLoadingFees) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.8),
          ),
        ),
      );
    }

    if (_feesErrorMessage != null) {
      return _buildInfoState(
        icon: Ionicons.alert_circle_outline,
        message: _feesErrorMessage!,
        actionLabel: 'Retry',
        onAction: _loadCreatedFees,
        messageColor: const Color(0xFFB3261E),
      );
    }

    final filtered = _filteredPayments;
    if (filtered.isEmpty) {
      final message = _paymentItems.isEmpty
          ? 'No created fees available yet.'
          : 'No fees in this tab.';

      return _buildInfoState(
        icon: Ionicons.receipt_outline,
        message: message,
        actionLabel: _paymentItems.isEmpty ? 'Refresh' : null,
        onAction: _paymentItems.isEmpty ? _loadCreatedFees : null,
        messageColor: const Color(0xFF6B7280),
      );
    }

    return Column(
      children: filtered
          .map(
            (payment) => _PaymentCard(
              payment: payment,
              onActionTap: () => _handlePaymentAction(payment),
              onNoteTap:
                  payment.status == StudentPaymentStatus.rejected &&
                      payment.rejectionNote.trim().isNotEmpty
                  ? () => _showRejectionNoteDialog(payment)
                  : null,
            ),
          )
          .toList(),
    );
  }

  void _showRejectionNoteDialog(StudentPaymentItem payment) {
    final rejectionNote = payment.rejectionNote.trim();
    if (rejectionNote.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Rejection Note',
          style: TextStyle(
            color: Color(0xFF003DA5),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          rejectionNote,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF003DA5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoState({
    required IconData icon,
    required String message,
    required Color messageColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: messageColor, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: messageColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF003DA5),
                side: BorderSide(
                  color: const Color(0xFF003DA5).withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(actionLabel),
            ),
          ],
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
                                '₱ ${_totalPayable.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 40,
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
                          _summary.academicYear,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFAFC0F1),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _summary.studentId,
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
    final tabs = StudentPaymentSeedData.tabs;

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

  Future<void> _handlePaymentAction(StudentPaymentItem payment) async {
    if (!StudentPaymentFilters.canSubmitProof(payment)) {
      return;
    }

    final didSubmit = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProofOfPaymentScreen(
          requirementId: payment.requirementId,
          paymentItem: payment.name,
          amountToPay: payment.amount,
        ),
      ),
    );

    if (!mounted || didSubmit != true) {
      return;
    }

    await _loadCreatedFees();
  }
}

class _SummaryYellowPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.77, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.50, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _PaymentCard extends StatelessWidget {
  final StudentPaymentItem payment;
  final VoidCallback onActionTap;
  final VoidCallback? onNoteTap;

  const _PaymentCard({
    required this.payment,
    required this.onActionTap,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = payment.status == StudentPaymentStatus.pending;
    final isRejected = payment.status == StudentPaymentStatus.rejected;
    final hasRejectionNote =
        isRejected && payment.rejectionNote.trim().isNotEmpty;
    final canSubmit = StudentPaymentFilters.canSubmitProof(payment);
    final statusChipColor = isPending
        ? const Color(0xFFFFC107).withOpacity(0.2)
        : isRejected
        ? const Color(0xFFC62828).withOpacity(0.14)
        : const Color(0xFFE3F2FD);
    final statusTextColor = isRejected
        ? const Color(0xFFC62828)
        : const Color(0xFF003DA5);

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
                  payment.name,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF003DA5),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                payment.amount,
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
                'Due: ${payment.dueDate}',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  if (hasRejectionNote && onNoteTap != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onNoteTap,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          Ionicons.document_text_outline,
                          color: const Color(0xFFC62828),
                          size: 16,
                        ),
                      ),
                    ),
                  if (hasRejectionNote && onNoteTap != null)
                    const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusChipColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      payment.status,
                      style: GoogleFonts.poppins(
                        color: statusTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Proof: ${payment.proof}',
            style: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            payment.obligation,
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
                disabledBackgroundColor: const Color(0xFFE6EAF2),
                disabledForegroundColor: const Color(0xFF6B7280),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: canSubmit ? onActionTap : null,
              child: Text(
                payment.actionText,
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
