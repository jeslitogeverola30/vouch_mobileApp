import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/admin_payment_submission_service.dart';
import '../../data/admin_payment_seed_data.dart';
import '../../data/payment_receiver_service.dart';
import '../../domain/payment_submission.dart';
import '../../domain/payment_submission_filters.dart';
import 'admin_created_fees_screen.dart';
import 'admin_create_fee_screen.dart';
import 'admin_edit_receiver_screen.dart';

import '../../../../core/config/app_constants.dart';          // ← your constants
import 'package:shared_preferences/shared_preferences.dart';
class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = PaymentSubmissionStatus.pending;
  String _selectedFeeType = PaymentSubmissionFilters.allFeeTypesLabel;

  PaymentReceiverReference _receiverReference =
      AdminPaymentSeedData.receiverReference;
  final List<PaymentSubmission> _submissions = <PaymentSubmission>[];
  bool _isLoadingSubmissions = false;
  bool _isApplyingSubmissionDecision = false;
  String? _submissionErrorMessage;
    DateTime? _lastRefreshTime;
  int _dailyRefreshCount = 0;
  String _currentDay = '';

  @override
  void initState() {
    super.initState();
    _loadReceiverReference();
    _loadSubmissions();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadReceiverReference({bool showErrorMessage = false}) async {
    try {
      final receiver = await PaymentReceiverService.instance
          .fetchActiveReceiver();
      if (!mounted || receiver == null) {
        return;
      }

      final nextName = receiver.name.trim().isNotEmpty
          ? receiver.name.trim()
          : _receiverReference.name;
      final nextRole = receiver.position.trim().isNotEmpty
          ? receiver.position.trim()
          : _receiverReference.role;
      final rawNumber = receiver.gcashNumber.trim().isNotEmpty
          ? receiver.gcashNumber.trim()
          : _receiverReference.number;

      setState(() {
        _receiverReference = PaymentReceiverReference(
          name: nextName,
          role: nextRole,
          number: PaymentReceiverDetails.formatGcashNumber(rawNumber),
        );
      });
    } on PostgrestException catch (error) {
      if (!mounted || !showErrorMessage) {
        return;
      }

      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : 'Unable to load receiver details from the database.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
    } catch (_) {
      if (!mounted || !showErrorMessage) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Unable to refresh receiver details right now. Please try again.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _loadSubmissions({bool showErrorMessage = false}) async {
    setState(() {
      _isLoadingSubmissions = true;
      _submissionErrorMessage = null;
    });

    try {
      final fetchedSubmissions = await AdminPaymentSubmissionService.instance
          .fetchSubmissionsForCurrentAdmin();

      if (!mounted) {
        return;
      }

      setState(() {
        _submissions
          ..clear()
          ..addAll(fetchedSubmissions);
        _isLoadingSubmissions = false;
        _submissionErrorMessage = null;

        final isCurrentFeeTypeValid =
            _selectedFeeType == PaymentSubmissionFilters.allFeeTypesLabel ||
            _submissions.any(
              (submission) => submission.courseName == _selectedFeeType,
            );

        if (!isCurrentFeeTypeValid) {
          _selectedFeeType = PaymentSubmissionFilters.allFeeTypesLabel;
        }
      });
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      final message = _resolveSubmissionErrorMessage(error);

      setState(() {
        _submissions.clear();
        _isLoadingSubmissions = false;
        _submissionErrorMessage = message;
        _selectedFeeType = PaymentSubmissionFilters.allFeeTypesLabel;
      });

      if (showErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : 'Unable to load student submissions right now.';

      setState(() {
        _submissions.clear();
        _isLoadingSubmissions = false;
        _submissionErrorMessage = message;
        _selectedFeeType = PaymentSubmissionFilters.allFeeTypesLabel;
      });

      if (showErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      const message =
          'Unable to load student submissions right now. Please try again.';

      setState(() {
        _submissions.clear();
        _isLoadingSubmissions = false;
        _submissionErrorMessage = message;
        _selectedFeeType = PaymentSubmissionFilters.allFeeTypesLabel;
      });

      if (showErrorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  String _resolveSubmissionErrorMessage(PostgrestException error) {
    final message = error.message.trim();
    if (message.isNotEmpty) {
      return message;
    }

    final code = error.code?.trim() ?? '';
    if (code.isNotEmpty) {
      return 'Supabase request failed ($code).';
    }

    return 'Unexpected database error while loading submissions.';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _feeTypeOptions {
    return PaymentSubmissionFilters.feeTypeOptions(_submissions);
  }

  List<PaymentSubmission> get _filteredSubmissions {
    return PaymentSubmissionFilters.filterSubmissions(
      submissions: _submissions,
      status: _selectedFilter,
      selectedFeeType: _selectedFeeType,
      query: _searchController.text,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case PaymentSubmissionStatus.approved:
        return const Color(0xFF2E7D32);
      case PaymentSubmissionStatus.rejected:
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF003DA5);
    }
  }

  Future<void> _showApprovalDialog(
    PaymentSubmission submission,
    bool isApprove,
  ) async {
    if (_isApplyingSubmissionDecision) {
      return;
    }

    final decision = await showDialog<_SubmissionDecisionResult>(
      context: context,
      useRootNavigator: false,
      builder: (_) => _SubmissionDecisionDialog(
        submission: submission,
        isApprove: isApprove,
      ),
    );

    if (!mounted || decision == null) {
      return;
    }

    await Future<void>.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    await _applySubmissionDecision(
      submission: submission,
      isApprove: decision.isApprove,
      reviewNote: decision.reviewNote,
    );
  }

  void _showRejectionNoteDialog({
    required String note,
    required String studentName,
  }) {
    final normalizedNote = note.trim();
    if (normalizedNote.isEmpty) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student: $studentName',
              style: const TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              normalizedNote,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF003DA5)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applySubmissionDecision({
    required PaymentSubmission submission,
    required bool isApprove,
    String? reviewNote,
  }) async {
    if (_isApplyingSubmissionDecision) {
      return;
    }

    final transactionId = int.tryParse(submission.id.trim());
    if (transactionId == null || transactionId <= 0) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Invalid submission id. Please refresh and try again.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isApplyingSubmissionDecision = true);

    try {
      await AdminPaymentSubmissionService.instance.updateSubmissionStatus(
        transactionId: transactionId,
        isApproved: isApprove,
        reviewNote: reviewNote,
      );

      if (!mounted) {
        return;
      }

      await _loadSubmissions(showErrorMessage: true);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isApprove ? 'Payment approved successfully' : 'Payment rejected',
          ),
          backgroundColor: isApprove ? Colors.green : Colors.red.shade600,
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resolveSubmissionErrorMessage(error)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } on ArgumentError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Unable to update submission status right now. Please try again.',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplyingSubmissionDecision = false);
      }
    }
  }

  void _showReceiptPreview(PaymentSubmission submission) {
    final receiptSource = submission.receiptAssetPath.trim();
    final hasReceipt = receiptSource.isNotEmpty;
    final isNetworkReceipt = _isNetworkReceiptPath(receiptSource);

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
                      child: !hasReceipt
                          ? const SizedBox(
                              height: 280,
                              child: Center(
                                child: Text(
                                  'Receipt is not available',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : isNetworkReceipt
                          ? Image.network(
                              receiptSource,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 280,
                                  child: Center(
                                    child: Text(
                                      'Unable to load receipt image',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              receiptSource,
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

  bool _isNetworkReceiptPath(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) {
      return false;
    }
    return uri.scheme == 'http' || uri.scheme == 'https';
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
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
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
    if (_selectedFeeType == PaymentSubmissionFilters.allFeeTypesLabel) {
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

   Future<void> _refreshScreen() async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // Load persisted values
    final lastRefreshStr = prefs.getString('admin_payments_last_refresh_time');
    if (lastRefreshStr != null) {
      _lastRefreshTime = DateTime.tryParse(lastRefreshStr);
    }
    _dailyRefreshCount = prefs.getInt('admin_payments_daily_refresh_count') ?? 0;
    _currentDay = prefs.getString('admin_payments_current_day') ?? '';

    // Reset daily count if it's a new day
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    if (_currentDay != today) {
      _dailyRefreshCount = 0;
      _currentDay = today;
    }

    // === 1. Check cooldown (1 minute) ===
    if (_lastRefreshTime != null) {
      final timeSinceLast = now.difference(_lastRefreshTime!);
      if (timeSinceLast < AppConstants.refreshCooldown) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait at least ${AppConstants.refreshCooldown.inMinutes} minute${AppConstants.refreshCooldown.inMinutes > 1 ? 's' : ''} before refreshing again.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    // === 2. Check daily limit (max 5) ===
    if (_dailyRefreshCount >= AppConstants.maxDailyRefreshes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have reached the maximum of 5 refreshes today. Please try again tomorrow.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // === ALLOW REFRESH ===
    if (mounted) {
      setState(() => _isLoadingSubmissions = true);
    }

    await Future.wait<void>([
      _loadReceiverReference(),
      _loadSubmissions(),
    ]);

    // Update tracking
    _lastRefreshTime = now;
    _dailyRefreshCount++;

    // Save to device storage
    await prefs.setString('admin_payments_last_refresh_time', now.toIso8601String());
    await prefs.setInt('admin_payments_daily_refresh_count', _dailyRefreshCount);
    await prefs.setString('admin_payments_current_day', today);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Refreshed successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    final filteredSubmissions = _filteredSubmissions;
    final submissionsSubtitle = _isLoadingSubmissions
        ? 'Loading student submissions...'
        : _submissionErrorMessage != null && _submissions.isEmpty
        ? 'Unable to load student submissions'
        : '${filteredSubmissions.length} result(s) in $_selectedFilter • ${_selectedFeeType == PaymentSubmissionFilters.allFeeTypesLabel ? 'all fees' : _selectedFeeType}';

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
            RefreshIndicator(
              onRefresh: _refreshScreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildReceiverReferenceCard(),
                    const SizedBox(height: 24),
                    _buildSearchAndFilterHeader(),
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
                      subtitle: submissionsSubtitle,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSubmissionListPanel(
                        submissions: filteredSubmissions,
                        isLoading: _isLoadingSubmissions,
                        errorMessage: _submissionErrorMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                heroTag: 'admin_payments_add_fab',
                onPressed: () async {
                  final didCreate = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const CreateFeeScreen()),
                  );

                  if (!mounted || didCreate != true) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fee created successfully!'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
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

  Widget _buildSearchAndFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search & Filter',
                  style: TextStyle(
                    color: Color(0xFF003DA5),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Narrow down payment submissions quickly',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminCreatedFeesScreen(),
                  ),
                );
              },
              icon: const Icon(Ionicons.list_outline, size: 16),
              label: const Text(
                'See Created Fees',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF003DA5),
                side: BorderSide(
                  color: const Color(0xFF003DA5).withOpacity(0.25),
                ),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
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
        height: 186,
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
                padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
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
                              const SizedBox(height: 5),
                              Text(
                                _receiverReference.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _receiverReference.role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            _receiverReference.number,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final didSave = await Navigator.of(context)
                                  .push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const EditReceiverDetailsScreen(),
                                    ),
                                  );

                              if (!mounted || didSave != true) {
                                return;
                              }

                              await _loadReceiverReference(
                                showErrorMessage: true,
                              );

                              if (!mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Receiver details updated successfully',
                                  ),
                                  backgroundColor: Color(0xFF2E7D32),
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

  Widget _buildSubmissionListPanel({
    required List<PaymentSubmission> submissions,
    required bool isLoading,
    String? errorMessage,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF003DA5).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? _buildSubmissionsLoadingState()
          : errorMessage != null && _submissions.isEmpty
          ? _buildSubmissionsErrorState(errorMessage)
          : submissions.isEmpty
          ? _buildEmptyState(isEmbedded: true)
          : Column(
              children: List.generate(
                submissions.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == submissions.length - 1 ? 0 : 12,
                  ),
                  child: _buildSubmissionCard(submissions[index]),
                ),
              ),
            ),
    );
  }

  Widget _buildSubmissionsLoadingState() {
    return const SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFF003DA5),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Loading submissions...',
              style: TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsErrorState(String message) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Icon(
            Ionicons.alert_circle_outline,
            color: const Color(0xFFC62828).withOpacity(0.9),
            size: 26,
          ),
          const SizedBox(height: 8),
          const Text(
            'Failed to load submissions',
            style: TextStyle(
              color: Color(0xFF003DA5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _loadSubmissions(showErrorMessage: true),
            icon: const Icon(Ionicons.refresh_outline, size: 15),
            label: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF003DA5),
              side: BorderSide(
                color: const Color(0xFF003DA5).withOpacity(0.25),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isEmbedded = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isEmbedded
            ? const Color(0xFF003DA5).withOpacity(0.03)
            : Colors.white,
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
    final isPending = submission.status == PaymentSubmissionStatus.pending;
    final isRejected = submission.status == PaymentSubmissionStatus.rejected;
    final hasRejectionNote = submission.rejectionNote.trim().isNotEmpty;
    final isDecisionLocked = _isApplyingSubmissionDecision;
    final hasReceipt = submission.receiptAssetPath.trim().isNotEmpty;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      submission.studentProgram,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      fontSize: 17,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSubmissionMetaChip(
                icon: Ionicons.pricetag_outline,
                text: submission.courseName,
              ),
              _buildSubmissionMetaChip(
                icon: Ionicons.wallet_outline,
                text: '${submission.paymentMethod} • ${submission.timeAgo}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF003DA5).withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF003DA5).withOpacity(0.1),
              ),
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
                TextButton.icon(
                  onPressed: hasReceipt
                      ? () => _showReceiptPreview(submission)
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF003DA5),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Ionicons.eye_outline, size: 15),
                  label: Text(
                    hasReceipt ? 'View Receipt' : 'No Receipt',
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
                  child: OutlinedButton.icon(
                    onPressed: isDecisionLocked
                        ? null
                        : () => _showApprovalDialog(submission, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC62828),
                      side: const BorderSide(color: Color(0xFFC62828)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Ionicons.close_outline, size: 16),
                    label: const Text(
                      'Reject',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDecisionLocked
                        ? null
                        : () => _showApprovalDialog(submission, true),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF003DA5),
                      disabledBackgroundColor: const Color(0xFF6B7280),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Ionicons.checkmark_outline, size: 16),
                    label: const Text(
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
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    submission.status == PaymentSubmissionStatus.approved
                        ? Ionicons.checkmark_circle_outline
                        : Ionicons.close_circle_outline,
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    submission.status == PaymentSubmissionStatus.approved
                        ? 'Already approved'
                        : 'Already rejected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isRejected && hasRejectionNote) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showRejectionNoteDialog(
                        note: submission.rejectionNote,
                        studentName: submission.studentName,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Ionicons.document_text_outline,
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmissionMetaChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF003DA5).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF003DA5), size: 13),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF003DA5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionDecisionResult {
  final bool isApprove;
  final String? reviewNote;

  const _SubmissionDecisionResult({
    required this.isApprove,
    required this.reviewNote,
  });
}

class _SubmissionDecisionDialog extends StatefulWidget {
  final PaymentSubmission submission;
  final bool isApprove;

  const _SubmissionDecisionDialog({
    required this.submission,
    required this.isApprove,
  });

  @override
  State<_SubmissionDecisionDialog> createState() =>
      _SubmissionDecisionDialogState();
}

class _SubmissionDecisionDialogState extends State<_SubmissionDecisionDialog> {
  final TextEditingController _noteController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        widget.isApprove ? 'Approve Payment' : 'Reject Payment',
        style: const TextStyle(
          color: Color(0xFF003DA5),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isApprove
                ? 'Approve ₱${widget.submission.amount} payment from ${widget.submission.studentName}?'
                : 'Reject ₱${widget.submission.amount} payment from ${widget.submission.studentName}?',
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          if (!widget.isApprove) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              onChanged: (_) {
                if (_validationMessage == null) {
                  return;
                }

                setState(() => _validationMessage = null);
              },
              decoration: InputDecoration(
                labelText: 'Rejection Note',
                hintText: 'Enter why this submission is rejected',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _validationMessage!,
                style: const TextStyle(
                  color: Color(0xFFC62828),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFF003DA5)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isApprove
                ? const Color(0xFF003DA5)
                : Colors.red,
          ),
          onPressed: () {
            final reviewNote = _noteController.text.trim();
            if (!widget.isApprove && reviewNote.isEmpty) {
              setState(
                () => _validationMessage = 'Rejection note is required.',
              );
              return;
            }

            Navigator.of(context).pop(
              _SubmissionDecisionResult(
                isApprove: widget.isApprove,
                reviewNote: widget.isApprove ? null : reviewNote,
              ),
            );
          },
          child: Text(
            widget.isApprove ? 'Approve' : 'Reject',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
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
