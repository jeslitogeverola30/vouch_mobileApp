import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/payment_requirement_service.dart';
import '../../data/payment_receiver_service.dart';

class AdminCreatedFeesScreen extends StatefulWidget {
  const AdminCreatedFeesScreen({super.key});

  @override
  State<AdminCreatedFeesScreen> createState() => _AdminCreatedFeesScreenState();
}

class _AdminCreatedFeesScreenState extends State<AdminCreatedFeesScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<PaymentRequirementDetails> _createdFees = const [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedDateSort = _sortNewest;

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _mutedText = Color(0xFF6B7280);
  static const String _sortNewest = 'Newest First';
  static const String _sortOldest = 'Oldest First';

  @override
  void initState() {
    super.initState();
    _loadCreatedFees();
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

  Future<void> _loadCreatedFees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fees = await PaymentRequirementService.instance
          .fetchRequirementsForCurrentAdmin();

      if (!mounted) {
        return;
      }

      setState(() => _createdFees = fees);
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _errorMessage = _supabaseErrorMessage(error));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to load created fees. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  List<PaymentRequirementDetails> get _visibleFees {
    final query = _searchController.text.trim().toLowerCase();
    final normalizedDigits = query.replaceAll(RegExp(r'\D'), '');

    final fees = _createdFees.where((fee) {
      if (query.isEmpty) {
        return true;
      }

      final matchesText =
          fee.title.toLowerCase().contains(query) ||
          fee.description.toLowerCase().contains(query) ||
          fee.receiverName.toLowerCase().contains(query);

      final matchesDigits =
          normalizedDigits.isNotEmpty &&
          fee.receiverGcash
              .replaceAll(RegExp(r'\D'), '')
              .contains(normalizedDigits);

      return matchesText || matchesDigits;
    }).toList();

    fees.sort((left, right) {
      final compare = left.id.compareTo(right.id);
      return _selectedDateSort == _sortNewest ? -compare : compare;
    });

    return fees;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ],
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
            RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(
                    text: 'Created ',
                    style: TextStyle(color: _royalBlue),
                  ),
                  TextSpan(
                    text: 'Fees',
                    style: TextStyle(color: _gold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(strokeWidth: 2.8),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Ionicons.alert_circle_outline,
                color: Color(0xFFB3261E),
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB3261E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _loadCreatedFees,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _royalBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_createdFees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.receipt_outline,
                color: _royalBlue.withOpacity(0.6),
                size: 30,
              ),
              const SizedBox(height: 10),
              const Text(
                'No created fees yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final visibleFees = _visibleFees;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 10),
              _buildSortByDateSection(),
            ],
          ),
        ),
        Expanded(
          child: visibleFees.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Ionicons.search, color: _mutedText, size: 28),
                        SizedBox(height: 10),
                        Text(
                          'No fees match your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _mutedText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  itemCount: visibleFees.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final fee = visibleFees[index];

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _royalBlue.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
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
                              Expanded(
                                child: Text(
                                  fee.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _royalBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₱${fee.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: _royalBlue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            fee.isMandatory ? 'OBLIGATORY' : 'NON-OBLIGATORY',
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            fee.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Receiver: ${fee.receiverName} • ${PaymentReceiverDetails.formatGcashNumber(fee.receiverGcash)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by title, details, or receiver',
        hintStyle: const TextStyle(
          color: _mutedText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Ionicons.search,
          color: _royalBlue.withOpacity(0.65),
          size: 18,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _royalBlue.withOpacity(0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _royalBlue.withOpacity(0.16)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _royalBlue, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildSortByDateSection() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _showSortByDatePicker,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _royalBlue.withOpacity(0.16)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _royalBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Ionicons.calendar_outline,
                  color: _royalBlue.withOpacity(0.8),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort by Date',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _selectedDateSort,
                      style: const TextStyle(
                        color: _royalBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: _royalBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Change',
                      style: TextStyle(
                        color: _royalBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Ionicons.chevron_down, color: _royalBlue, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSortByDatePicker() async {
    final selectedSort = await showModalBottomSheet<String>(
      context: context,
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
                const Text(
                  'Sort Fees by Date',
                  style: TextStyle(
                    color: _royalBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose how created fees are ordered.',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSortChoiceTile(
                  value: _sortNewest,
                  icon: Ionicons.arrow_down_circle_outline,
                  title: _sortNewest,
                  subtitle: 'Recently created fees appear first',
                ),
                const SizedBox(height: 10),
                _buildSortChoiceTile(
                  value: _sortOldest,
                  icon: Ionicons.arrow_up_circle_outline,
                  title: _sortOldest,
                  subtitle: 'Earlier created fees appear first',
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedSort == null || selectedSort == _selectedDateSort) {
      return;
    }

    setState(() => _selectedDateSort = selectedSort);
  }

  Widget _buildSortChoiceTile({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = value == _selectedDateSort;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(value),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? _royalBlue.withOpacity(0.08)
                : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? _royalBlue.withOpacity(0.45)
                  : _royalBlue.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _royalBlue.withOpacity(0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isSelected ? _royalBlue : _mutedText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? _royalBlue
                            : const Color(0xFF1F2937),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Ionicons.checkmark_circle,
                  color: _royalBlue,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
